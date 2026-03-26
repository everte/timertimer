// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/timertimer_web.ex",
    "../lib/timertimer_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        'brand': "#FD4F00",
        'green-key': '#00ff00',
        'white': "#FFFFFF",
        'tvBlue-dark': "#1D4560",
        'tvBlue-medium': "#357FB9",
        'tvBlue-light' : "#92D4F6",
        'tvBlue-lighter': "#B7E1F9",
        'tvBlue-lightest': "#D7ECFB",
        'tvRed': "#C32030",
        'tvGreen': "#BFBA2D",
      },

      backgroundImage: {
        'test': 'url(/images/background.jpg)'
      },

      backgroundColor: {
        'stream': '#00ff00'
      },

      textColor: theme => theme('colors'),
      
      fontFamily: {
        tvThin:"Qanelas Thin",
        tvExtraLight:"Qanelas ExtraLight",
        tvLight:"Qanelas Light",
        tvRegular:"Qanelas Regular",
        tvMedium:"Qanelas Medium",
        tvSemiBold:"Qanelas SemiBold",
        tvBold:"Qanelas Bold",
        tvExtraBold: "Qanelas ExtraBold",
        tvHeavy: "Qanelas Heavy",
        tvBlack: "Qanelas Black"
      }
    },
  },
  safelist: [
    "items-(start|center|end)",
    "visible", "invisible"
  ],
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
      matchComponents({
        "hero": ({ name, fullPath }) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, { values })
    })
  ]
}
