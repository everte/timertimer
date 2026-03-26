defmodule TimertimerWeb.AthleteLive.FormComponent do
  use TimertimerWeb, :live_component

  alias Timertimer.Competition

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage athlete records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="athlete-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:short_name]} type="text" label="Short name" />
        <.input field={@form[:birth_date]} type="date" label="Birth date" />
        <.input field={@form[:country]} type="text" label="Country" />
        <.input field={@form[:country2]} type="text" label="Country2" />
        <.input
          field={@form[:gender]}
          type="select"
          label="Gender"
          prompt="Choose a value"
          options={Ecto.Enum.values(Timertimer.Competition.Athlete, :gender)}
        />
        <.input field={@form[:notes]} type="text" label="Notes" />

        <div class="space-y-2">
          <.label for="picture_upload">Profile Picture</.label>
          <.live_file_input upload={@uploads.picture} />
          <%= if @uploads.picture.entries != [] do %>
            <div class="mt-2">
              <%= for entry <- @uploads.picture.entries do %>
                <div class="flex items-center gap-4 my-2">
                  <.live_img_preview entry={entry} width="100" />
                  <div>
                    <span>{entry.client_name}</span>
                    <button
                      type="button"
                      phx-click="cancel-upload"
                      phx-value-ref={entry.ref}
                      phx-target={@myself}
                      class="text-red-500 text-sm"
                    >
                      Cancel
                    </button>
                    <%= if entry.progress < 100 do %>
                      <div class="w-full bg-gray-200 rounded-full h-2.5">
                        <div
                          class="bg-blue-600 h-2.5 rounded-full"
                          style={"width: #{entry.progress}%"}
                        >
                        </div>
                      </div>
                    <% end %>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>

          <%= if @athlete.picture_data do %>
            <div class="mt-4">
              <div class="text-sm text-gray-600">Current picture:</div>
              <img src={data_url(@athlete)} width="100" class="mt-1 rounded-md" />
              <button
                type="button"
                phx-click="remove-picture"
                phx-target={@myself}
                class="text-red-500 text-sm mt-2"
              >
                Remove picture
              </button>
            </div>
          <% end %>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Athlete</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  defp data_url(athlete) do
    "data:image/png;base64,#{Base.encode64(athlete.picture_data)}"
  end

  @impl true
  def update(%{athlete: athlete} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Competition.change_athlete(athlete))
     end)
     |> allow_upload(:picture,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       max_file_size: 5_000_000
     )}
  end

  @impl true
  def handle_event("validate", %{"athlete" => athlete_params}, socket) do
    changeset = Competition.change_athlete(socket.assigns.athlete, athlete_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"athlete" => athlete_params}, socket) do
    athlete_params = handle_picture_upload(socket, athlete_params)
    save_athlete(socket, socket.assigns.action, athlete_params)
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :picture, ref)}
  end

  def handle_event("remove-picture", _, socket) do
    changeset =
      socket.assigns.athlete
      |> Competition.change_athlete(%{picture_data: nil})

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  defp handle_picture_upload(socket, athlete_params) do
    case uploaded_entries(socket, :picture) do
      {[entry], _} ->
        picture_data =
          consume_uploaded_entry(socket, entry, fn %{path: path} ->
            {:ok, File.read!(path)}
          end)

        Map.put(athlete_params, "picture_data", picture_data)

      {[], _} ->
        athlete_params
    end
  end

  defp save_athlete(socket, :edit, athlete_params) do
    case Competition.update_athlete(socket.assigns.athlete, athlete_params) do
      {:ok, athlete} ->
        notify_parent({:saved, athlete})

        {:noreply,
         socket
         |> put_flash(:info, "Athlete updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_athlete(socket, :new, athlete_params) do
    case Competition.create_athlete(athlete_params) do
      {:ok, athlete} ->
        notify_parent({:saved, athlete})

        {:noreply,
         socket
         |> put_flash(:info, "Athlete created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
