window.WB = window.WB ? {}

WB.bindEvents = (wb, canvas) ->
    tool = new fabric['PencilBrush'](canvas)

    ## Fabric
    TogetherJS.on 'ready', =>
        $('.tjs-start').fadeOut()

        canvas.on 'mouse:down', (data) =>
            TogetherJS.send
                type: 'drawStart'
                point: canvas.getPointer data.e
            wb.isDrawing = true

        canvas.on 'mouse:move', (data) =>
            if wb.isDrawing
                TogetherJS.send
                    type: 'drawContinue'
                    point: canvas.getPointer data.e

        canvas.on 'mouse:up', =>
            if wb.isDrawing
                wb.isDrawing = false
                TogetherJS.send
                    type: 'drawEnd'

    ## TogetherJS
    TogetherJS.on 'close', =>
        $('.tjs-start').fadeIn()

    TogetherJS.hub.on 'togetherjs.hello', =>
        TogetherJS.send
            type: 'init'
            data: wb.getSnapshot()

    TogetherJS.hub.on 'init', (snapshot) =>
        wb.loadSnapshot snapshot.data

    TogetherJS.hub.on 'drawStart', (data) =>
        tool.onMouseDown data.point

    TogetherJS.hub.on 'drawContinue', (data) =>
        tool.onMouseMove data.point

    TogetherJS.hub.on 'drawEnd', =>
        tool.onMouseUp()

##
## Literally Fabric / Whiteboard
##
class WB.Core
    constructor: (@id) ->
        @canvas = @_createCanvas @id
        @_resizeCanvas $(window).outerWidth(), $(window).outerHeight()

        @canvas.isDrawingMode = true
        @isDrawing = false

        WB.bindEvents this, @canvas

    _createCanvas: (id) ->
        new fabric.Canvas id

    _resizeCanvas: (width, height) ->
        @canvas.setHeight height
        @canvas.setWidth width

    getSnapshot: ->
        JSON.stringify @canvas

    loadSnapshot: (data) ->
        @canvas.loadFromJSON data, @canvas.renderAll.bind(@canvas)

Whiteboard = new WB.Core 'js-whiteboard'