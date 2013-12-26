window.WB = window.WB ? {}

##
## Literally Kinetic / Whiteboard
##
class WB.Core
    constructor: (@id) ->
        @canvas = @_createCanvas @id
        @_resizeCanvas $(window).outerWidth(), $(window).outerHeight()

        @canvas.isDrawingMode = true

    _createCanvas: (id) ->
        new fabric.Canvas id

    _resizeCanvas: (width, height) ->
        @canvas.setHeight height
        @canvas.setWidth width

Whiteboard = new WB.Core 'js-whiteboard'