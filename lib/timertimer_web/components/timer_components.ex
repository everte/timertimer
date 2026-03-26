defmodule TimertimerWeb.TimerComponents do
  use Phoenix.Component
  attr :name, :string, required: true
  attr :elapsed, :integer, required: true
  attr :countries, :list, default: []
  attr :align, :string, default: "items-center"

  def player(assigns) do
    name_parts = String.split(assigns.name, " ", parts: 2)
    [first_name, last_name] = if length(name_parts) == 2, do: name_parts, else: [assigns.name, ""]

    [country, country2] =
      if length(assigns.countries) == 0, do: [nil, nil], else: assigns.countries

    assigns =
      assigns
      |> assign(:first_name, first_name)
      |> assign(:last_name, last_name)
      |> assign(:country, country)
      |> assign(:country2, country2)

    ~H"""
    <div class="bg-white p-3 w-80 text-center label-time-em timerTime-big">
      {Timertimer.Timer.format_ms(@elapsed)}
    </div>
    <div class="bg-white flex items-center gap-x-2 py-3 px-6">
      <%= if @country2 != nil && @country2 != "" do %>
        <.render_flag country={@country2} style="w-12" />
      <% end %>
      <%= if @country != nil && @country != "" do %>
        <.render_flag country={@country} style="w-12 mr-3" />
      <% end %>
      <%= if @first_name != "" do %>
        <span class="label-firstName timerName-big">{@first_name}</span>
        <span class="label-lastName timerName-big">{@last_name}</span>
      <% else %>
        <span class="font-tvLight">-</span>
      <% end %>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :align, :string, default: "left"
  attr :countries, :list, default: []

  def svo_name(assigns) do
    [first_name, last_name] = String.split(assigns.name, " ", parts: 2)
    [country, country2] = assigns.countries

    assigns =
      assigns
      |> assign(:first_name, first_name)
      |> assign(:last_name, last_name)
      |> assign(:country, country)
      |> assign(:country2, country2)

    ~H"""
    <div class="bg-white flex items-center gap-x-2 py-3 px-6 text-6xl">
      <%= if @country2 != nil do %>
        <.render_flag country={@country2} style="w-16" />
      <% end %>
      <.render_flag country={@country} style="w-16 mr-3" />
      <span class="label-firstName mr-2">{@first_name}</span>
      <span class="label-lastName">{@last_name}</span>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :picture_data, :any, required: true
  attr :align, :string, default: "left"
  attr :countries, :list, default: []
  attr :size, :string, default: "small"

  def svo_picture(assigns) do
    [first_name, last_name] = String.split(assigns.name, " ", parts: 2)

    sizes = %{
      "tiny" => %{
        container: "max-w-[32px] w-[32px] p-3",
        # Very small image container
        image_container: "w-6 h-6",
        # Tiny flags
        flag_size: "w-2 h-2",
        # Very small text
        text_size: "text-[6px]",
        # Minimal margin
        name_margin: "mt-1"
      },
      "small" => %{
        container: "max-w-[220px] w-[220px] p-3",
        image_container: "w-52 h-52",
        flag_size: "w-12 h-12",
        text_size: "text-2xl",
        name_margin: "mt-6"
      },
      "big" => %{
        container: "max-w-[440px] w-[440px] p-4",
        image_container: "w-104 h-104",
        flag_size: "w-24 h-24",
        text_size: "text-4xl",
        name_margin: "mt-4"
      },
      "big-vs" => %{
        container: "max-w-[360px] w-[360px] p-4",
        image_container: "w-full",
        flag_size: "w-24",
        text_size: "",
        name_margin: "mt-4"
      },
      "small-svo" => %{
        container: "max-w-[340px] w-[340px] p-3",
        image_container: "w-full",
        flag_size: "w-20",
        text_size: "text-4xl",
        name_margin: "mt-3"
      }
    }

    size_config = Map.get(sizes, assigns.size, sizes["small"])

    assigns =
      assigns
      |> assign(:container_style, size_config.container)
      |> assign(:image_container_class, size_config.image_container)
      |> assign(:flag_size, size_config.flag_size)
      |> assign(:text_size_class, size_config.text_size)
      |> assign(:name_margin_class, size_config.name_margin)
      |> assign_new(:align, fn -> "center" end)
      |> assign(:first_name, first_name)
      |> assign(:last_name, last_name)

    ~H"""
    <div class={"flex flex-col items-#{@align}"}>
      <div class={"bg-white #{@container_style}"}>
        <div class="flex flex-col items-center h-full">
          <div class={"relative #{@image_container_class}"}>
            <%= if @picture_data do %>
              <div class="w-full h-full overflow-hidden">
                <img
                  src={"data:image/jpeg;base64,#{Base.encode64(@picture_data)}"}
                  alt={@name}
                  class="w-full h-full object-cover"
                />
              </div>

              <div class="absolute bottom-0 right-0">
                <div class=" bg-white">
                  <.render_flags countries={@countries} size={@flag_size} />
                </div>
              </div>
            <% end %>
          </div>

          <div class={"#{@name_margin_class} text-center w-full flex flex-col items-center justify-center"}>
            <div class={"#{@text_size_class} label-firstName line-clamp-1 break-words"}>
              {@first_name}
            </div>
            <div class={"#{@text_size_class} label-lastName line-clamp-1 break-words"}>
              {@last_name}
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :picture_data, :any, required: true
  attr :align, :string, default: "left"
  attr :countries, :list, default: []
  attr :size, :string, default: "small"
  attr :box_width_class, :string, default: "xs"

  def bracket_picture(assigns) do
    [first_name, last_name] = String.split(assigns.name, " ", parts: 2)

    base_config = %{
      container: "width: 100%; height: 100%; max-width: none; max-height: none;",
      image_container: "w-full",
      padding: "p-0.5"
    }

    flag_sizes = %{
      "sm" => "w-10",
      "md" => "w-14",
      "lg" => "w-20"
    }

    styles_last_name = %{
      "sm" => "text-[0.9rem]  font-tvBold",
      "md" => "text-[1.2rem] font-tvBold",
      "lg" => "text-[1.8rem]  font-tvBold"
    }

    styles_first_name = %{
      "sm" => "text-xl font-tvHeavy",
      "md" => "text-2xl font-tvHeavy",
      "lg" => "text-4xl font-tvHeavy"
    }

    width_class = Map.get(assigns, :box_width_class, "md")
    flag_size = Map.get(flag_sizes, width_class, flag_sizes["md"])
    style_first_name = Map.get(styles_first_name, width_class, styles_first_name["md"])
    style_last_name = Map.get(styles_last_name, width_class, styles_last_name["md"])

    assigns =
      assigns
      |> assign(:container_style, base_config.container)
      |> assign(:image_container_class, base_config.image_container)
      |> assign(:flag_size, flag_size)
      |> assign(:style_first_name, style_first_name)
      |> assign(:style_last_name, style_last_name)
      |> assign(:padding_class, base_config.padding)
      |> assign_new(:align, fn -> "center" end)
      |> assign(:first_name, first_name)
      |> assign(:last_name, last_name)

    ~H"""
    <div class="w-full h-full flex justify-center items-center">
      <div class={"flex flex-col items-#{@align} w-full h-full"}>
        <div class={"bg-white #{@padding_class} flex flex-col w-full h-full"} style={@container_style}>
          <div class="flex flex-col h-full">
            <div class={"relative flex-none #{@image_container_class}"}>
              <%= if @picture_data do %>
                <div class="w-full">
                  <img
                    src={"data:image/jpeg;base64,#{Base.encode64(@picture_data)}"}
                    alt={@name}
                    class="w-full object-cover"
                  />
                </div>

                <div class="absolute bottom-0 right-0">
                  <div class="bg-white">
                    <.render_flags countries={@countries} size={@flag_size} />
                  </div>
                </div>
              <% end %>
            </div>

            <div class="text-center pt-1 w-full flex-1 flex flex-col place-content-center">
              <div class={"#{@style_first_name} line-clamp-1 break-words leading-[1.3]"}>
                {@first_name}
              </div>
              <div class={"#{@style_last_name} line-clamp-1 break-words leading-[1.3]"}>
                {@last_name}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def question_mark(assigns) do
    ~H"""
    <svg
      width="60%"
      fill="#ffffff"
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      viewBox="0 0 973.1 973.1"
      xml:space="preserve"
    >
      <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
      <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
      <g id="SVGRepo_iconCarrier">
        <g>
          <path d="M502.29,788.199h-47c-33.1,0-60,26.9-60,60v64.9c0,33.1,26.9,60,60,60h47c33.101,0,60-26.9,60-60v-64.9 C562.29,815,535.391,788.199,502.29,788.199z">
          </path>

          <path d="M170.89,285.8l86.7,10.8c27.5,3.4,53.6-12.4,63.5-38.3c12.5-32.7,29.9-58.5,52.2-77.3c31.601-26.6,70.9-40,117.9-40 c48.7,0,87.5,12.8,116.3,38.3c28.8,25.6,43.1,56.2,43.1,92.1c0,25.8-8.1,49.4-24.3,70.8c-10.5,13.6-42.8,42.2-96.7,85.9 c-54,43.7-89.899,83.099-107.899,118.099c-18.4,35.801-24.8,75.5-26.4,115.301c-1.399,34.1,25.8,62.5,60,62.5h49 c31.2,0,57-23.9,59.8-54.9c2-22.299,5.7-39.199,11.301-50.699c9.399-19.701,33.699-45.701,72.699-78.1 C723.59,477.8,772.79,428.4,795.891,392c23-36.3,34.6-74.8,34.6-115.5c0-73.5-31.3-138-94-193.4c-62.6-55.4-147-83.1-253-83.1 c-100.8,0-182.1,27.3-244.1,82c-52.8,46.6-84.9,101.8-96.2,165.5C139.69,266.1,152.39,283.5,170.89,285.8z">
          </path>
        </g>
      </g>
    </svg>
    """
  end

  attr :countries, :list, default: []
  attr :size, :string, default: "w-10 h-10 "

  def render_flags(assigns) do
    countries_string = Enum.join(assigns.countries, ",")

    assigns =
      assign(assigns, :countries_string, countries_string)

    countries =
      countries_string
      |> String.downcase()
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)

    assigns = assign(assigns, :countries, countries)

    ~H"""
    <div class="flex items-center">
      <%= for country <- @countries do %>
        <span class="pl-1 pt-1 flex items-center">
          <%= case country do %>
            <% "bel" -> %>
              <Flagpack.bel class={"#{@size} flex items-center justify-center"} />
            <% "fra" -> %>
              <Flagpack.fra class={"#{@size} flex items-center justify-center"} />
            <% "gbr" -> %>
              <Flagpack.gbr class={"#{@size} flex items-center justify-center"} />
            <% "lux" -> %>
              <Flagpack.lux class={"#{@size} flex items-center justify-center"} />
            <% "che" -> %>
              <Flagpack.che class={"#{@size} flex items-center justify-center"} />
            <% "deu" -> %>
              <Flagpack.deu class={"#{@size} flex items-center justify-center"} />
            <% "col" -> %>
              <Flagpack.col class={"#{@size} flex items-center justify-center"} />
            <% "arg" -> %>
              <Flagpack.arg class={"#{@size} flex items-center justify-center"} />
            <% "pol" -> %>
              <Flagpack.pol class={"#{@size} flex items-center justify-center"} />
            <% "bra" -> %>
              <Flagpack.bra class={"#{@size} flex items-center justify-center"} />
            <% "nld" -> %>
              <Flagpack.nld class={"#{@size} flex items-center justify-center"} />
          <% end %>
        </span>
      <% end %>
    </div>
    """
  end

  attr :country, :string, default: ""
  attr :style, :string, default: ""

  def render_flag(assigns) do
    ~H"""
    <%= case @country do %>
      <% "bel" -> %>
        <Flagpack.bel class={"#{@style}"} />
      <% "fra" -> %>
        <Flagpack.fra class={"#{@style}"} />
      <% "gbr" -> %>
        <Flagpack.gbr class={"#{@style}"} />
      <% "lux" -> %>
        <Flagpack.lux class={"#{@style}"} />
      <% "che" -> %>
        <Flagpack.che class={"#{@style}"} />
      <% "deu" -> %>
        <Flagpack.deu class={"#{@style}"} />
      <% "col" -> %>
        <Flagpack.col class={"#{@style}"} />
      <% "arg" -> %>
        <Flagpack.arg class={"#{@style}"} />
      <% "pol" -> %>
        <Flagpack.pol class={"#{@style}"} />
      <% "bra" -> %>
        <Flagpack.bra class={"#{@style}"} />
      <% "nld" -> %>
        <Flagpack.nld class={"#{@style}"} />
      <% nil -> %>
        <div class={"#{@style}"}>&nbsp;</div>
    <% end %>
    """
  end
end
