var webSocketPath = window.location.pathname.substr(0, window.location.pathname.lastIndexOf("/")) + "/websocket"
var webSocketURL = "ws://" + window.location.hostname +  webSocketPath
var webSocket;
var isConnected;

var canvas;
var context;
var divStatistics;

var statisticsInitialTime;
var statisticsEnqueuedFrameCount;
var statisticsEmptyFrameCount;
var statisticsFramesRenderedCount;

var frameQueue;

function onLoad() {
    // Log
    divStatistics = document.getElementById("divStatistics");

    // Statistics
    statisticsInitialTime = performance.now();
    statisticsEnqueuedFrameCount = 0;
    statisticsFramesRenderedCount = 0;
    statisticsEmptyFrameCount = 0;
    statisticsMaxFrameQueueCount = 0;
    
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

    // Frame Queue
    frameQueue = [];

    // Connection
    isConnected = false;
    webSocket = establishConnection();
}

function logMessage(message) {
    console.log(message);
}

function logError(message) {
    console.error(message);
}

function logStatistics(message) {
    divStatistics.innerHTML = message;
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
    isConnected = true;
    logMessage("CONNECTED");
    
    // Notify sizes
    notifyWindowSize(window.innerWidth, window.innerHeight);
    notifyCanvasSize(canvas.getAttribute("width"), canvas.getAttribute("height"));

    // Request update frame event
    window.requestAnimationFrame(onUpdateFrame);
}

function onUpdateFrame(timestamp) {
    // Update statistics
    statisticsFramesRenderedCount += 1;

    // Process frame if available
    if (frameQueue.length > 0) {
	statisticsMaxFrameQueueCount = Math.max(statisticsMaxFrameQueueCount, frameQueue.length);
	frame = frameQueue.shift();
	processCommands(frame);
    } else {
	statisticsEmptyFrameCount += 1;
    }

    // Display statistics
    elapsedMilliseconds = performance.now() - statisticsInitialTime;
    renderedFramesPerSecond = statisticsFramesRenderedCount / elapsedMilliseconds * 1000;
    enqueuedFramesPerSecond = statisticsEnqueuedFrameCount / elapsedMilliseconds * 1000;
    emptyFramesPerSecond = statisticsEmptyFrameCount / elapsedMilliseconds * 1000;
    logStatistics("Rendered FPS: " + renderedFramesPerSecond.toFixed(2) +
		  " Enqueued FPS: " + enqueuedFramesPerSecond.toFixed(2) +
		  " Empty FPS: " + emptyFramesPerSecond.toFixed(2) +
		  " Max Frame Queue: " + statisticsMaxFrameQueueCount);

    // Request next update frame event if still connected
    if (isConnected) {
	window.requestAnimationFrame(onUpdateFrame)
    }
}

function onClose(event) {
    isConnected = false;
    logMessage("DISCONNECTED. Code: " + event.code + " Reason: " + event.reason);
}

function onMessage(event) {
    enqueueFrame(event.data);
}

function onError(event) {
    logErrorMessage(event.data);
}

function doSend(message) {
    webSocket.send(message);
}

// Images
function onImageLoaded(event) {
    let id = event.target.id;
    let message = "onImageLoaded|" + id;
    doSend(message);
}

function onImageError(event) {
    let id = event.target.id;
    let message = "onImageError|" + id;
    doSend(message);
}

function createImage(id, sourceURL) {
    let divImages = document.getElementById("divImages");
    let img = document.createElement("img");
    img.id = id;
    img.src = sourceURL;
    img.style.display = "none";
    img.addEventListener("load", onImageLoaded);
    img.addEventListener("error", onImageError);
    divImages.appendChild(img);

    let message = "onImageProcessed|" + id;
    doSend(message);
}

// Canvas
function onClick(event) {
    let message = "onClick|" + event.clientX + "|" + event.clientY;
    doSend(message);
}

function onMouseDown(event) {
    let message = "onMouseDown|" + event.clientX + "|" + event.clientY;
    doSend(message);
}

function onMouseUp(event) {
    let message = "onMouseUp|" + event.clientX + "|" + event.clientY;
    doSend(message);
}

function onMouseMove(event) {
    let message = "onMouseMove|" + event.clientX + "|" + event.clientY;
    doSend(message);
}

function onKeyDown(event) {
    let key      = event.key
    let code     = event.code
    let ctrlKey  = event.ctrlKey
    let shiftKey = event.shiftKey
    let altKey   = event.altKey
    let metaKey  = event.metaKey

    let message = "onKeyDown|"   + key + "|" + code + "|" + ctrlKey + "|" + shiftKey + "|" + altKey + "|" + metaKey;
    doSend(message);

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
    let message = "onCanvasResize|" + width + "|" + height;
    doSend(message);
}

function notifyWindowSize(width, height) {
    let message = "onWindowResize|" + width + "|" + height;
    doSend(message);
}

function enqueueFrame(commandMessages) {
    frameQueue.push(commandMessages);
    
    // Statistics
    statisticsEnqueuedFrameCount += 1;
}

function processCommands(commandMessages) {
    commandMessages.split("||").forEach(processCommand)
}

function processCommand(commandMessage, commandIndex) {
    let commandAndArguments = commandMessage.split("|");
    if (commandAndArguments.length < 1) {
	logErrorMessage("processCommand: Unable to process empty commandAndArguments list");
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
	logErrorMessage("Unknown command: " + command);
    }
}

function processArc(arguments) {
    if (arguments.length != 6) {
	logErrorMessage("processArc: Requires six arguments");
	return;
    }
    let centerX = arguments.shift();
    let centerY = arguments.shift();
    let radius  = arguments.shift();
    let startAngle = arguments.shift();
    let endAngle   = arguments.shift();
    let antiClockwise = arguments.shift() === "true";
    context.arc(centerX, centerY, radius, startAngle, endAngle, antiClockwise);
}

function processArcTo(arguments) {
    if (arguments.length != 5) {
	logErrorMessage("processArcTo: Requires five arguments");
	return;
    }
    let controlPoint1x = arguments.shift();
    let controlPoint1y = arguments.shift();
    let controlPoint2x = arguments.shift();
    let controlPoint2y = arguments.shift();
    let radius = arguments.shift();
    context.arcTo(controlPoint1x, controlPoint1y, controlPoint2x, controlPoint2y, radius);
}

function processBeginPath(arguments) {
    if (arguments.length != 0) {
	logErrorMessage("processBeginPath: Requires zero arguments");
	return;
    }
    context.beginPath();
}

function processBezierCurveTo(arguments) {
    if (arguments.length != 6) {
	logErrorMessage("processBezierCurveTo: Requires six arguments");
	return;
    }
    let controlPoint1x = arguments.shift();
    let controlPoint1y = arguments.shift();
    let controlPoint2x = arguments.shift();
    let controlPoint2y = arguments.shift();
    let endPointX = arguments.shift();
    let endPointY = arguments.shift();
    context.bezierCurveTo(controlPoint1x, controlPoint1y, controlPoint2x, controlPoint2y, endPointX, endPointY);
		    
}

function processCanvasSetSize(arguments) {
    if  (arguments.length != 2) {
	logErrorMessage("processCanvasSetSize: Requires two arguments");
	return;
    }
    let width = arguments.shift();
    let height = arguments.shift();
    canvas.width = width;
    canvas.height = height;
    notifyCanvasSize(width, height);
}

function processClearRect(arguments) {
    if (arguments.length != 4) {
	logErrorMessage("processClearRect: Requires four arguments");
	return;
    }
    let x = arguments.shift();
    let y = arguments.shift();
    let width = arguments.shift();
    let height = arguments.shift();
    context.clearRect(x, y, width, height);
}

function processClosePath(arguments) {
    if (arguments.length != 0) {
	logErrorMessage("processClosePath: Requires zero arguments");
	return;
    }
    context.closePath();
}

function processCreateImage(arguments) {
    if (arguments.length != 2) {
	logErrorMessage("processCreateImage: Requires two arguments");
	return;
    }
    let id = arguments.shift();
    let sourceURL = arguments.shift();
    createImage(id, sourceURL);
}

function processDrawImage(arguments) {
    if (arguments.length != 3 && arguments.length != 5 && arguments.length != 9) {
	logErrorMessage("processDrawImage: Requires three, five, or nine arguments");
	return;
    }

    let id = arguments.shift();
    let img = document.getElementById(id);
    
    if (arguments.length == 2) {
	let dx = arguments.shift();
	let dy = arguments.shift();
	context.drawImage(img, dx, dy);
    } else if (arguments.length == 4) {
	let dx = arguments.shift();
	let dy = arguments.shift();
	let dWidth = arguments.shift();
	let dHeight = arguments.shift();
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
	context.drawImage(img, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight);
    }
}

function processEllipse(arguments) {
    if (arguments.length != 8) {
	logErrorMessage("processEllipse: Requires eight arguments");
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
    context.ellipse(x, y, radiusX, radiusY, rotation, startAngle, endAngle, antiClockwise);
}

function processFill(arguments) {
    if (arguments.length != 0) {
	logErrorMessage("processFill: Requires zero arguments");
	return;
    }
    context.fill();
}

function processFillRect(arguments) {
    if (arguments.length != 4) {
	logErrorMessage("processFillRect: Requires four arguments");
	return;
    }
    let x = arguments.shift();
    let y = arguments.shift();
    let width = arguments.shift();
    let height = arguments.shift();
    context.fillRect(x, y, width, height);
}

function processFillStyle(arguments) {
    if (arguments.length != 1) {
	logErrorMessage("procesFillStyle: Requires one argument");
	return;
    }
    let style = arguments.shift();
    context.fillStyle = style;
}

function processFillText(arguments) {
    if (arguments.length != 3) {
	logErrorMessage("processFillText: Requires three arguments");
	return;
    }
    let text = arguments.shift();
    let x = arguments.shift();
    let y = arguments.shift();
    context.fillText(text, x, y);
}

function processFont(arguments) {
    if (arguments.length != 1) {
	logErrorMessage("processFont: Requires one argument");
	return;
    }
    let font = arguments.shift();
    context.font = font;
}

function processLineWidth(arguments) {
    if (arguments.length != 1) {
	logErrorMessage("processLineWidth: Requires one argument");
	return;
    }
    let width = arguments.shift();
    context.lineWidth = width;
}

function processLineTo(arguments) {
    if (arguments.length != 2) {
	logErrorMessage("processLineTo: Requires two arguments");
	return;
    }
    let x = arguments.shift();
    let y = arguments.shift();
    context.lineTo(x, y)
}

function processMoveTo(arguments) {
    if (arguments.length != 2) {
	logErrorMessage("processMoveTo: Requires two arguments");
	return;
    }
    let x = arguments.shift();
    let y = arguments.shift();
    context.moveTo(x, y)
}

function processQuadraticCurveTo(arguments) {
    if (arguments.length != 4) {
	logErrorMessage("processQuadraticCurveTo: Requires four arguments");
	return;
    }
    let controlPointX = arguments.shift();
    let controlPointY = arguments.shift();
    let endPointX = arguments.shift();
    let endPointY = arguments.shift();
    context.quadraticCurveTo(controlPointX, controlPointY, endPointX, endPointY);
}

function processStroke(arguments) {
    if (arguments.length != 0) {
	logErrorMessage("processStroke: Requires zero arguments");
	return;
    }
    context.stroke();
}

function processStrokeRect(arguments) {
    if (arguments.length != 4) {
	logErrorMessage("processStrokeRect: Requires four arguments");
	return;
    }
    let x = arguments.shift();
    let y = arguments.shift();
    let width = arguments.shift();
    let height = arguments.shift();
    context.strokeRect(x, y, width, height);
}

function processStrokeStyle(arguments) {
    if (arguments.length != 1) {
	logErrorMessage("procesStrokeStyle: Requires one argument");
	return;
    }
    let style = arguments.shift();
    context.strokeStyle = style;
}

function processStrokeText(arguments) {
    if (arguments.length != 3) {
	logErrorMessage("processStrokeText: Requires three arguments");
	return;
    }
    let text = arguments.shift();
    let x = arguments.shift();
    let y = arguments.shift();
    context.strokeText(text, x, y);
}

document.addEventListener("DOMContentLoaded", onLoad);
