// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Hooks from "./hooks"


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let socketUrl = window.location.pathname.startsWith("/embed/") ? "/embed/live" : "/live"
let liveSocket = new LiveSocket(socketUrl, Socket, {
  hooks: Hooks,
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken }
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


// Enable resizing content to fit window
document.addEventListener("DOMContentLoaded", (e) => {
  var mainDiv = document.querySelector(".tv");

  if (!mainDiv) return;

  var initialWidth = mainDiv.offsetWidth;
  var initialHeight = mainDiv.offsetHeight;

  function getScaleFactor() {
    var xScale = window.innerWidth / initialWidth;
    var yScale = window.innerHeight / initialHeight;
    return Math.min(xScale, yScale);
  }
  document.documentElement.style.setProperty('--resize-scale', `${getScaleFactor()}`);
  window.addEventListener('resize', () => {
    document.documentElement.style.setProperty('--resize-scale', `${getScaleFactor()}`);
  });
})


window.copyToClipboard = function (text, buttonElement) {
  if (!navigator.clipboard) {
    console.error('Clipboard API not available.');
    alert('Copying to clipboard is not supported in this context (requires HTTPS or localhost).');
    return;
  }

  navigator.clipboard.writeText(text).then(() => {
    const originalText = buttonElement.textContent;
    buttonElement.textContent = 'Copied!';
    buttonElement.disabled = true;

    setTimeout(() => {
      buttonElement.textContent = originalText;
      buttonElement.disabled = false;
    }, 1500);

  }).catch(err => {
    console.error('Failed to copy text: ', err);
    alert('Failed to copy link.');
  });
}
