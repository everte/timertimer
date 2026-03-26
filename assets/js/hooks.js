let CountdownHook = {
    mounted() {
        this.handleEvent("countdown_event", ({ message }) => {
            console.log("handle event: ", message);
            this.updateCircles(message);
            this.playAudio(message);
        });
    },

    playAudio(message) {
        let audioElement = document.getElementById("countdown-audio");
        if (!audioElement) return;

        let audioSrc;
        switch (message) {
            case "2":
            case "1":
                audioSrc = "/audio/beep-short.mp3";
                break;
            case "go":
                audioSrc = "/audio/beep-long.mp3";
                break;
            case "false_start":
                audioSrc = "/audio/beep-alert2.mp3";
                break;
            default:
                return;
        }

        audioElement.src = audioSrc;
        audioElement.play().catch(error => console.log("Audio playback error:", error));
    },

    updateCircles(message) {
        let circle1 = document.getElementById("circle-1");
        let circle2 = document.getElementById("circle-2");
        let svgContainer = document.getElementById("svg-container");

        if (!circle1 || !circle2 || !svgContainer) return;

        switch (message) {
            case "2":
                svgContainer.style.display = "block";
                circle1.setAttribute("fill", "green");
                circle2.setAttribute("fill", "red");
                break;
            case "1":
                circle1.setAttribute("fill", "green");
                circle2.setAttribute("fill", "green");
                break;
            case "go":
                svgContainer.style.display = "none";
                break;
            case "show":
                svgContainer.style.display = "block";
                circle1.setAttribute("fill", "red");
                circle2.setAttribute("fill", "red");
                break;
        }
    }
};


let BuzzControllerHook = {
    mounted() {
        console.log("BuzzControllerHook mounted");

        if (typeof window.Controller === 'undefined') {
            console.error("Controller object not available. Scripts may not have loaded correctly.");
            return;
        }

        if (typeof window.BuzzController === 'undefined') {
            console.error("BuzzController object not available. Scripts may not have loaded correctly.");
            return;
        }

        console.log("Controller objects available");

        try {
            window.BuzzController.search();
            console.log("BuzzController search initiated");
        } catch (e) {
            console.error("Error starting controller search:", e);
        }

        this.controllerFoundHandler = (event) => {
            const controller = event.detail.controller;
            console.log(`Controller found: ${controller.name} (index: ${controller.index})`);
            this.pushEvent("controller_found", {
                index: controller.index,
                name: controller.name
            });
        };
        window.addEventListener('gc.controller.found', this.controllerFoundHandler);

        this.buttonPressHandler = (event) => {
            const button = event.detail;
            console.log(`Button press: ${button.name} on controller ${button.controllerIndex}`);
            // send event to our LV component with button press!
            this.pushEvent("button_press", {
                controllerIndex: button.controllerIndex,
                name: button.name,
                pressed: button.pressed,
                value: button.value,
                time: button.time
            });
        };
        window.addEventListener('gc.button.press', this.buttonPressHandler);

        this.gamepadConnectedHandler = (e) => {
            console.log(`Gamepad connected via Gamepad API: ${e.gamepad.id} (index: ${e.gamepad.index})`);
        };
        window.addEventListener("gamepadconnected", this.gamepadConnectedHandler);
    },

    destroyed() {
        window.removeEventListener('gc.controller.found', this.controllerFoundHandler);
        window.removeEventListener('gc.button.press', this.buttonPressHandler);
        window.removeEventListener('gamepadconnected', this.gamepadConnectedHandler);
    }
};

export default {
    CountdownHook,
    BuzzControllerHook
};
