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
    window.addEventListener("keydown", onKeyDown);
    window.addEventListener("resize", onWindowResize);
    canvas.addEventListener("click", onClick);
    canvas.addEventListener("mousedown", onMouseDown);
    canvas.addEventListener("mouseup", onMouseUp);
    canvas.addEventListener("mousemove", onMouseMove);
    

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
	let onMessage = "Debug collect mode is now on.";
	logMessage(onMessage, divReceived);
	logMessage(onMessage, divTransmitted);
	debugCollectMode = 1;
    } else {
	let offMessage = "Debug collect mode is now off.";
	logMessage(offMessage, divReceived);
	logMessage(offMessage, divTransmitted);
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
    
    // Notify sizes
    notifyWindowSize(window.innerWidth, window.innerHeight);
    notifyCanvasSize(canvas.getAttribute("width"), canvas.getAttribute("height"));
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
function onImageLoaded(event) {
    let id = event.target.id;
    logDebugMessage("onImageLoaded(" + id + ")", divTransmitted);
    let message = "onImageLoaded|" + id;
    doSend(message);
}

function onImageError(event) {
    let id = event.target.id;
    logDebugMessage("onImageError(" + id + ")", divTransmitted);
    let message = "onImageError|" + id;
    doSend(message);
}

function createImage(id, sourceURL) {
    let divImages = document.getElementById("divImages");
    let img = document.createElement("img");
    img.id = id;
    img.src = sourceURL;
    img.style.display = debugAvailable ? "visible" : "none";
    img.addEventListener("load", onImageLoaded);
    img.addEventListener("error", onImageError);
    divImages.appendChild(img);

    logDebugMessage("onImageProcessed(" + id + ")", divTransmitted);
    let message = "onImageProcessed|" + id;
    doSend(message);
}

// Canvas
function onClick(event) {
    logDebugMessage("onClick(" + event.clientX + ", " + event.clientY + ")", divTransmitted);
    let message = "onClick|" + event.clientX + "|" + event.clientY;
    doSend(message);
}

function onMouseDown(event) {
    logDebugMessage("onMouseDown(" + event.clientX + ", " + event.clientY + ")", divTransmitted);
    let message = "onMouseDown|" + event.clientX + "|" + event.clientY;
    doSend(message);
}

function onMouseUp(event) {
    logDebugMessage("onMouseUp(" + event.clientX + ", " + event.clientY + ")", divTransmitted);
    let message = "onMouseUp|" + event.clientX + "|" + event.clientY;
    doSend(message);
}

function onMouseMove(event) {
    logDebugMessage("onMouseMove(" + event.clientX + ", " + event.clientY + ")", divTransmitted);
    let message = "onMouseMove|" + event.clientX + "|" + event.clientY;
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

function onWindowResize(event) {
    let width = event.target.innerWidth;
    let height = event.target.innerHeight;
    notifyWindowSize(width, height);
}

function notifyCanvasSize(width, height) {
    logDebugMessage("onCanvasResize(" + width + "," + height + ")", divTransmitted);
    let message = "onCanvasResize|" + width + "|" + height;
    doSend(message);
}

function notifyWindowSize(width, height) {
    logDebugMessage("onWindowResize(" + width + "," + height + ")", divTransmitted);
    let message = "onWindowResize|" + width + "|" + height;
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
    case "canvasSetSize":
	processCanvasSetSize(arguments);
	break;
    case "closePath":
	processClosePath(arguments);
	break;
    case "clearRect":
	processClearRect(arguments);
	break;
    case "createImage":
	processCreateImage(arguments);
	break;
    case "drawImage":
	processDrawImage(arguments);
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

function processCanvasSetSize(arguments) {
    if  (arguments.length != 2) {
	logErrorMessage("processCanvasSetSize: Requires two arguments", divReceived);
	return;
    }
    let width = arguments.shift();
    let height = arguments.shift();
    logDebugMessage("canvasSetSize(" + width + "," + height + ")", divReceived);
    canvas.width = width;
    canvas.height = height;
    notifyCanvasSize(width, height);
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

function processCreateImage(arguments) {
    if (arguments.length != 2) {
	logErrorMessage("processCreateImage: Requires two arguments", divReceived);
	return;
    }
    let id = arguments.shift();
    let sourceURL = arguments.shift();
    logDebugMessage("processCreateImage(" + id + "," + sourceURL + ")", divReceived);
    createImage(id, sourceURL);
}

function processDrawImage(arguments) {
    if (arguments.length != 3 && arguments.length != 5 && arguments.length != 9) {
	logErrorMessage("processDrawImage: Requires three, five, or nine arguments", divReceived);
	return;
    }

    let id = arguments.shift();
    let img = document.getElementById(id);
    
    if (arguments.length == 2) {
	let dx = arguments.shift();
	let dy = arguments.shift();
	logDebugMessage("processDrawImage(" + id + "," + dx + "," + dy + ")", divReceived);
	context.drawImage(img, dx, dy);
    } else if (arguments.length == 4) {
	let dx = arguments.shift();
	let dy = arguments.shift();
	let dWidth = arguments.shift();
	let dHeight = arguments.shift();
	logDebugMessage("processDrawImage(" + id + "," + dx + "," + dy + "," + dWidth + "," + dHeight + ")", divReceived);
	context.drawImage(img, dx, dy, dWidth, dHeight);
    } else if (arguments.length == 8) {
	let sx = arguments.shift();
	let sy = arguments.shift();
	let sWidth = arguments.shift();
	let sHeight = arguments.shift();
	let dx = arguments.shift();
	let dy = arguments.shift();
	let dWidth = arguments.shift();
	let dHeight = arguments.shift();
	logDebugMessage("processDrawImage(" + id + "," +
			sx + "," + sy + "," + sWidth + "," + sHeight + "," +
			dx + "," + dy + "," + dWidth + "," + dHeight + ")", divReceived);
	context.drawImage(img, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight);
    }
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
