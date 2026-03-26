defmodule TimertimerWeb.ViewHelpers do
  def pagination_opts do
    [
      ellipsis_attrs: [class: "ellipsis"],
      ellipsis_content: "‥",
      next_link_attrs: [
        class:
          "px-3 py-2 leading-tight text-gray-500 bg-white border border-gray-300 rounded-r-lg hover:bg-gray-100 hover:text-gray-700"
      ],
      # next_link_content: next_icon(),
      page_links: :hide,
      # {:ellipsis, 7},
      # pagination_link_aria_label: &"#{&1}ページ目へ",
      previous_link_attrs: [
        class:
          "px-3 py-2 ml-0 leading-tight text-gray-500 bg-white border border-gray-300 rounded-l-lg hover:bg-gray-100 hover:text-gray-700"
      ]
      # previous_link_content: previous_icon()
    ]
  end

  def table_opts do
    [
      container: true,
      container_attrs: [class: "table-container"],
      # no_results_content: content_tag(:p, do: "Nothing found."),
      table_attrs: [class: "w-full text-sm text-left text-gray-700 table-auto"],
      thead_tr_attrs: [
        class: "text-xs text-gray-700 uppercase bg-gray-50 "
      ],
      thead_th_attrs: [class: "py-3"],
      tbody_attrs: [class: ""],
      tbody_tr_attrs: [
        class: "bg-white border-b hover:bg-zinc-50"
      ],
      tbody_td_attrs: [class: "py-4 hover:cursor-pointer"]
    ]
  end


  def format_datetime(datetime, format \\ "{YYYY}-{0M}-{0D} {h24}:{m}:{s}") do
    datetime
    |> Timex.to_datetime()
    |> Timex.format!(format)
  end
end
