var webSocketPath = window.location.pathname.substr(0, window.location.pathname.lastIndexOf("/")) + "/websocket"
var webSocketURL = "ws://" + window.location.hostname +  webSocketPath
var webSocket;

var canvas;
var context;
var divRecieved;
var divTransmitted;

var debugAvailable;
var debugDisplayMode;
var debugCollectMode;

function onLoad() {
    // Log
    divReceived = document.getElementById("divReceived");
    divTransmitted = document.getElementById("divTransmitted");

    // Debug mode
    // We set this before Canvas  because it may alter size of canvas
    let urlParameters = new URLSearchParams(window.location.search);
    debugAvailable = urlParameters.get("debug") == 1
    if (debugAvailable) {
	setDebugDisplayMode(1);
	setDebugCollectMode(1);
    } else {
	// Disable debugging display
	setDebugDisplayMode(0);
	setDebugCollectMode(0);

	document.getElementById("trTop").style.height = "100%";
	document.getElementById("trBottom").style.height = "0%";
    }
    
    // Canvas
    canvas = document.getElementById("canvasMain");
    let canvasContainerRect = canvas.parentElement.getBoundingClientRect();
    canvas.setAttribute("width", canvasContainerRect.width);
    canvas.setAttribute("height", canvasContainerRect.height);
    context = canvas.getContext("2d");

    // Register events
    window.onkeydown = function (event) {onKeyDown(event)};
    canvas.onclick = function (event) {onClick(event)};

    // Connection
    webSocket = establishConnection();
}

function setDebugDisplayMode(mode) {
    if (mode == 1) {
	divReceived.style.display = "block";
	divTransmitted.style.display = "block";

	debugDisplayMode = 1;
    } else {
	divReceived.style.display = "none";
	divTransmitted.style.display = "none";
	debugDisplayMode = 0;
    }
}

function toggleDebugDisplayMode() {
    if (debugDisplayMode == 1) {
	setDebugDisplayMode(0);
    } else {
	setDebugDisplayMode(1);
    }
}

function setDebugCollectMode(mode) {
    if (mode == 1) {
	let offMessage = "Debug collect mode is now on.";
	logMessage(offMessage, divReceived);
	logMessage(offMessage, divTransmitted);
	debugCollectMode = 1;
    } else {
	let onMessage = "Debug collect mode is now off.";
	logMessage(onMessage, divReceived);
	logMessage(onMessage, divTransmitted);
	debugCollectMode = 0;
    }
}

function toggleDebugCollectMode() {
    if (debugCollectMode == 1) {
	setDebugCollectMode(0);
    } else {
	setDebugCollectMode(1);
    }
}

function logMessage(message, div) {
    let element = document.createElement("p");
    element.innerHTML = message;
    div.insertBefore(element, null);
    div.scrollTop = div.scrollHeight; 
}

function logDebugMessage(message, div) {
    if (debugCollectMode == 1) {
	logMessage(message, div);
    }
}

function logErrorMessage(message, div) {
    let errorMessage = "<span style='color: red;'>" + message + "</span>";
    logMessage(errorMessage, div);
}

function establishConnection() {
    let wsconnection = new WebSocket(webSocketURL);
    wsconnection.onopen = function (event) {onOpen(event)};
    wsconnection.onclose = function (event) {onClose(event)};
    wsconnection.onmessage = function (event) {onMessage(event)};
    wsconnection.onerror = function (event) {onError(event)};
    return wsconnection;
}

// Web Socket
function onOpen(event) {
    logMessage("<span style='color: blue;'>CONNECTED</span>", divReceived);
    
    // Establish size
    let width = canvas.getAttribute("width");
    let height = canvas.getAttribute("height");
    notifySize(width, height);
}

function onClose(event) {
    logMessage("<span style='color: blue;'>DISCONNECTED. Code: " + event.code + " Reason: " + event.reason + "</span>", divReceived);
}

function onMessage(event) {
    processCommands(event.data);
}

function onError(event) {
    logErrorMessage(event.data, divReceived);
}

function doSend(message) {
    webSocket.send(message);
}

// Images
function notifyImageLoaded(imageId) {
    doSend("imageLoaded|"+imageId);
}

function loadImage(imageId, sourceURL) {
    let divImages = document.getElementById("divImages");
    let img = document.createElement("img");
    img.src = sourceURL;
    img.style.display = "none";
    img.addEventListener("load", notifyImageLoaded(imageId));
    img.onLoad = function() {notifyImageLoaded(imageId)};
}

// Canvas
function onClick(event) {
    logDebugMessage("onClick(" + event.clientX + ", " + event.clientY + ")", divTransmitted);
    let message = "onClick|" + event.clientX + "|" + event.clientY;
    doSend(message);
}

function onKeyDown(event) {
    let code = event.code

    switch (code) {
    case "F1":
	toggleDebugDisplayMode();
	break;
    case "F2":
	toggleDebugCollectMode();
	break;
    }

}

function notifySize(width, height) {
    logDebugMessage("onSetSize(" + width + ", " + height + ")", divTransmitted);
    let message = "onSetSize|" + width + "|" + height;
    doSend(message);
}

function processCommands(commandMessages) {
    commandMessages.split("||").forEach(processCommand)
}

function processCommand(commandMessage, commandIndex) {
    let commandAndArguments = commandMessage.split("|");
    if (commandAndArguments.length < 1) {
	logErrorMessage("processCommand: Unable to process empty commandAndArguments list", divReceived);
	return;
    }
    let command = commandAndArguments.shift();
    let arguments = commandAndArguments;
    
    switch (command) {
    case "ping":
	break;

    case "arc":
	processArc(arguments);
	break;
    case "arcTo":
	processArcTo(arguments);
	break;
    case "beginPath":
	processBeginPath(arguments);
	break;
    case "bezierCurveTo":
	processBezierCurveTo(arguments);
	break;
    case "closePath":
	processClosePath(arguments);
	break;
    case "clearRect":
	processClearRect(arguments);
	break;
    case "ellipse":
	processEllipse(arguments);
	break;
    case "fill":
	processFill(arguments);
	break;
    case "fillRect":
	processFillRect(arguments);
	break;
    case "fillStyle":
	processFillStyle(arguments);
	break;
    case "fillText":
	processFillText(arguments);
	break;
    case "font":
	processFont(arguments);
	break;
    case "lineTo":
	processLineTo(arguments);
	break;
    case "lineWidth":
	processLineWidth(arguments);
	break;
    case "moveTo":
	processMoveTo(arguments);
	break;
    case "quadraticCurveTo":
	processQuadraticCurveTo(arguments);
	break;
    case "stroke":
	processStroke(arguments);
	break;
    case "strokeStyle":
	processStrokeStyle(arguments);
	break;
    case "strokeRect":
	processStrokeRect(arguments);
	break;
    case "strokeText":
	processStrokeText(arguments);
	break;
    default:
	logErrorMessage("Unknown command: " + command, divReceived);
    }
}

function processArc(arguments) {
    if (arguments.length != 6) {
	logErrorMessage("processArc: Requires six arguments", divReceived);
	return;
    }
    let centerX = arguments.shift();
    let centerY = arguments.shift();
    let radius  = arguments.shift();
    let startAngle = arguments.shift();
    let endAngle   = arguments.shift();
    let antiClockwise = arguments.shift() === "true";
    logDebugMessage("arc(" + centerX + "," + centerY + "," + radius + "," + startAngle + "," + endAngle + "," + antiClockwise + ")", divReceived);
    context.arc(centerX, centerY, radius, startAngle, endAngle, antiClockwise);
}

function processArcTo(arguments) {
    if (arguments.length != 5) {
	logErrorMessage("processArcTo: Requires five arguments", divReceived);
	return;
    }
    let controlPoint1x = arguments.shift();
    let controlPoint1y = arguments.shift();
    let controlPoint2x = arguments.shift();
    let controlPoint2y = arguments.shift();
    let radius = arguments.shift();
    logDebugMessage("arcTo(" + controlPoint1x + "," + controlPoint1y + "," + controlPoint2x + "," + controlPoint2y + "," + radius + ")", divReceived);
    context.arcTo(controlPoint1x, controlPoint1y, controlPoint2x, controlPoint2y, radius);
}

function processBeginPath(arguments) {
    if (arguments.length != 0) {
	logErrorMessage("processBeginPath: Requires zero arguments", divReceived);
	return;
    }
    logDebugMessage("beginPath()", divReceived);
    context.beginPath();
}

function processBezierCurveTo(arguments) {
    if (arguments.length != 6) {
	logErrorMessage("processBezierCurveTo: Requires six arguments", divReceived);
	return;
    }
    let controlPoint1x = arguments.shift();
    let controlPoint1y = arguments.shift();
    let controlPoint2x = arguments.shift();
    let controlPoint2y = arguments.shift();
    let endPointX = arguments.shift();
    let endPointY = arguments.shift();
    logDebugMessage("bezierCurveTo(" + controlPoint1x + "," + controlPoint1y + "," + controlPoint2x + "," + controlPoint2y + "," +
		    endPointX + "," + endPointY + ")", divReceived);
    context.bezierCurveTo(controlPoint1x, controlPoint1y, controlPoint2x, controlPoint2y, endPointX, endPointY);
		    
}

function processClearRect(arguments) {
    if (arguments.length != 4) {
	logErrorMessage("processClearRect: Requires four arguments", divReceived);
	return;
    }
    let x = arguments.shift();
    let y = arguments.shift();
    let width = arguments.shift();
    let height = arguments.shift();
    logDebugMessage("clearRect(" + x + "," + y + "," + width + "," + height + ")", divReceived);
    context.clearRect(x, y, width, height);
}

function processClosePath(arguments) {
    if (arguments.length != 0) {
	logErrorMessage("processClosePath: Requires zero arguments", divReceived);
	return;
    }
    logDebugMessage("closePath()", divReceived);
    context.closePath();
}

function processEllipse(arguments) {
    if (arguments.length != 8) {
	logErrorMessage("processEllipse: Requires eight arguments", divReceived);
	return;
    }
    let x = arguments.shift();
    let y = arguments.shift();
    let radiusX = arguments.shift();
    let radiusY = arguments.shift();
    let rotation = arguments.shift();
    let startAngle = arguments.shift();
    let endAngle = arguments.shift();
    let antiClockwise = arguments.shift() === "true";
    logDebugMessage("ellipse(" + x + "," + y + "," +
		    radiusX + "," + radiusY + "," +
		    rotation + "," +
		    startAngle + "," + endAngle + "," +
		    antiClockwise + ")", divReceived);
    context.ellipse(x, y, radiusX, radiusY, rotation, startAngle, endAngle, antiClockwise);
}

function processFill(arguments) {
    if (arguments.length != 0) {
	logErrorMessage("processFill: Requires zero arguments", divReceived);
	return;
    }
    logDebugMessage("fill()", divReceived);
    context.fill();
}

function processFillRect(arguments) {
    if (arguments.length != 4) {
	logErrorMessage("processFillRect: Requires four arguments", divReceived);
	return;
    }
    let x = arguments.shift();
    let y = arguments.shift();
    let width = arguments.shift();
    let height = arguments.shift();
    logDebugMessage("fillRect(" + x + "," + y + "," + width + "," + height + ")", divReceived);
    context.fillRect(x, y, width, height);
}

function processFillStyle(arguments) {
    if (arguments.length != 1) {
	logErrorMessage("procesFillStyle: Requires one argument", divReceived);
	return;
    }
    let style = arguments.shift();
    logDebugMessage("fillStyle=" + style, divReceived);
    context.fillStyle = style;
}

function processFillText(arguments) {
    if (arguments.length != 3) {
	logErrorMessage("processFillText: Requires three arguments", divReceived);
	return;
    }
    let text = arguments.shift();
    let x = arguments.shift();
    let y = arguments.shift();
    logDebugMessage("fillText(" + text + "," + x + "," + y + ")", divReceived);
    context.fillText(text, x, y);
}

function processFont(arguments) {
    if (arguments.length != 1) {
	logErrorMessage("processFont: Requires one argument", divReceived);
	return;
    }
    let font = arguments.shift();
    logDebugMessage("font=" + font, divReceived);
    context.font = font;
}

function processLineWidth(arguments) {
    if (arguments.length != 1) {
	logErrorMessage("processLineWidth: Requires one argument", divReceived);
	return;
    }
    let width = arguments.shift();
    logDebugMessage("lineWidth=" + width, divReceived);
    context.lineWidth = width;
}

function processLineTo(arguments) {
    if (arguments.length != 2) {
	logErrorMessage("processLineTo: Requires two arguments", divReceived);
	return;
    }
    let x = arguments.shift();
    let y = arguments.shift();
    logDebugMessage("lineTo(" + x + "," + y + ")", divReceived);
    context.lineTo(x, y)
}

function processMoveTo(arguments) {
    if (arguments.length != 2) {
	logErrorMessage("processMoveTo: Requires two arguments", divReceived);
	return;
    }
    let x = arguments.shift();
    let y = arguments.shift();
    logDebugMessage("moveTo(" + x + "," + y + ")", divReceived);
    context.moveTo(x, y)
}

function processQuadraticCurveTo(arguments) {
    if (arguments.length != 4) {
	logErrorMessage("processQuadraticCurveTo: Requires four arguments", divReceived);
	return;
    }
    let controlPointX = arguments.shift();
    let controlPointY = arguments.shift();
    let endPointX = arguments.shift();
    let endPointY = arguments.shift();
    logDebugMessage("quadraticCurveTo(" + controlPointX + "," + controlPointY + "," + endPointX + "," + endPointY + ")", divReceived);
    context.quadraticCurveTo(controlPointX, controlPointY, endPointX, endPointY);
}

function processStroke(arguments) {
    if (arguments.length != 0) {
	logErrorMessage("processStroke: Requires zero arguments", divReceived);
	return;
    }
    logDebugMessage("stroke()", divReceived);
    context.stroke();
}

function processStrokeRect(arguments) {
    if (arguments.length != 4) {
	logErrorMessage("processStrokeRect: Requires four arguments", divReceived);
	return;
    }
    let x = arguments.shift();
    let y = arguments.shift();
    let width = arguments.shift();
    let height = arguments.shift();
    logDebugMessage("strokeRect(" + x + "," + y + "," + width + "," + height + ")", divReceived);
    context.strokeRect(x, y, width, height);
}

function processStrokeStyle(arguments) {
    if (arguments.length != 1) {
	logErrorMessage("procesStrokeStyle: Requires one argument", divReceived);
	return;
    }
    let style = arguments.shift();
    logDebugMessage("strokeStyle=" + style, divReceived);
    context.strokeStyle = style;
}

function processStrokeText(arguments) {
    if (arguments.length != 3) {
	logErrorMessage("processStrokeText: Requires three arguments", divReceived);
	return;
    }
    let text = arguments.shift();
    let x = arguments.shift();
    let y = arguments.shift();
    logDebugMessage("strokeText(" + text + "," + x + "," + y + ")", divReceived);
    context.strokeText(text, x, y);
}

document.addEventListener("DOMContentLoaded", onLoad);
