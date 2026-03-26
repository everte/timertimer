defmodule TimertimerWeb.TimeLive.FormComponent do
  use TimertimerWeb, :live_component

  alias Timertimer.Competition
  alias Timertimer.Timer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage time records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="time-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:start_time]} type="datetime-local" label="Start Time" step="1" />
        <.input
          field={@form[:time_string]}
          type="text"
          label="Time (MM:SS.HH)"
          placeholder="00:00.00"
        />
        <.input
          field={@form[:athlete_id]}
          type="select"
          label="Athlete"
          options={Enum.map(@athletes, &{&1.name, &1.id})}
        />
        <.input
          field={@form[:round]}
          type="select"
          label="Round"
          options={Ecto.Enum.values(Timertimer.Competition.Time, :round)}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Time</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{time: time} = assigns, socket) do
    time_with_string = add_time_string(time)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Competition.change_time(time_with_string))
     end)}
  end

  @impl true
  def handle_event("validate", %{"time" => time_params}, socket) do
    changeset =
      socket.assigns.time
      |> Competition.change_time(time_params)
      |> validate_time_string()

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"time" => time_params}, socket) do
    time_params = convert_time_string_to_ms(time_params)
    save_time(socket, socket.assigns.action, time_params)
  end

  defp save_time(socket, :edit, time_params) do
    case Competition.update_time(socket.assigns.time, time_params) do
      {:ok, time} ->
        notify_parent({:saved, time})

        {:noreply,
         socket
         |> put_flash(:info, "Time updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_time(socket, :new, time_params) do
    case Competition.create_time(time_params) do
      {:ok, time} ->
        notify_parent({:saved, time})

        {:noreply,
         socket
         |> put_flash(:info, "Time created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp add_time_string(time) do
    time_string = Timer.format_ms(time.time) |> String.trim_leading(" ")
    Map.put(time, :time_string, time_string)
  end

  defp convert_time_string_to_ms(time_params) do
    case Timer.parse_time_string(time_params["time_string"]) do
      {:error, _} ->
        time_params

      milliseconds ->
        Map.put(time_params, "time", milliseconds)
    end
  end

  defp validate_time_string(changeset) do
    time_string =
      Ecto.Changeset.get_field(changeset, :time_string)

    if time_string do
      case Timer.parse_time_string(time_string) do
        {:error, :invalid_format} ->
          Ecto.Changeset.add_error(changeset, :time_string, "must be in format MM:SS.HH")

        milliseconds ->
          Ecto.Changeset.put_change(changeset, :time, milliseconds)
      end
    else
      changeset
    end
  end
end
