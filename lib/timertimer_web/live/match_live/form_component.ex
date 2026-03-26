defmodule TimertimerWeb.MatchLive.FormComponent do
  use TimertimerWeb, :live_component

  alias Timertimer.Competition

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage match records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="match-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={f[:gender]}
          type="select"
          label="Gender"
          prompt="Choose a value"
          options={Ecto.Enum.values(Timertimer.Competition.Match, :gender)}
        />
        <.input
          field={f[:round]}
          type="select"
          label="Round"
          options={[
            Test: :test,
            Qualification: :qualification,
            Quarter: :quarter,
            Half: :half,
            "Small Final": :small_final,
            Final: :final
          ]}
        />
        <.input field={f[:round_name]} type="text" label="Round Name" />
        <.input field={f[:position]} type="number" label="Position" />
        <.input
          field={f[:athlete1_id]}
          type="select"
          label="Athlete 1"
          options={[{"Not determined", nil} | @athlete_options]}
        />
        <.input
          field={f[:athlete2_id]}
          type="select"
          label="Athlete 2"
          options={[{"Not determined", nil} | @athlete_options]}
        />
        <.input
          field={f[:winner_id]}
          type="select"
          label="Winner"
          options={[{"Not determined", nil} | @athlete_options]}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Match</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{match: match} = assigns, socket) do
    changeset = Competition.change_match(match)

    athlete_options = Competition.list_athletes_for_select()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:athlete_options, athlete_options)}
  end

  @impl true
  def handle_event("validate", %{"match" => match_params}, socket) do
    changeset =
      socket.assigns.match
      |> Competition.change_match(match_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"match" => match_params}, socket) do
    save_match(socket, socket.assigns.action, match_params)
  end

  defp save_match(socket, :edit, match_params) do
    case Competition.update_match(socket.assigns.match, match_params) do
      {:ok, _match} ->
        {:noreply,
         socket
         |> put_flash(:info, "Match updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_match(socket, :new, match_params) do
    case Competition.create_match(match_params) do
      {:ok, _match} ->
        {:noreply,
         socket
         |> put_flash(:info, "Match created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
