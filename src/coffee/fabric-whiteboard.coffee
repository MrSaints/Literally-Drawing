window.WB = window.WB ? {}

##
## TogetherJS Events
##
WB.Collaborate = (wb, canvas) ->
    @TJS = TogetherJS

    # @TODO Client specific instances
    @tool = new fabric['PencilBrush'](canvas)
    @isDrawing = false

    @broadcastObject = (data) =>
        #console.log data

    canvas.on
        'object:moving': @broadcastObject,
        'object:scaling': @broadcastObject,
        'object:resizing': @broadcastObject,
        'object:rotating': @broadcastObject

    # Bind Whiteboard events
    @TJS.on 'ready', =>
        canvas.on 'mouse:down', (data) =>
            return if not canvas.isDrawingMode
            @isDrawing = true
            TogetherJS.send
                type: 'drawStart'
                point: canvas.getPointer data.e

        canvas.on 'mouse:move', (data) =>
            return if not @isDrawing
            TogetherJS.send
                type: 'drawContinue'
                point: canvas.getPointer data.e

        canvas.on 'mouse:up', (data) =>
            return if not @isDrawing
            @isDrawing = false
            TogetherJS.send
                type: 'drawEnd'

    # Bind hub events
    @TJS.hub.on 'togetherjs.hello', =>
        TogetherJS.send
            type: 'init'
            data: wb.getSnapshot()

    @TJS.hub.on 'init', (snapshot) =>
        wb.loadSnapshot snapshot.data

    @TJS.hub.on 'drawStart', (data) =>
        @tool.onMouseDown data.point

    @TJS.hub.on 'drawContinue', (data) =>
        @tool.onMouseMove data.point

    @TJS.hub.on 'drawEnd', =>
        @tool.onMouseUp()

##
## Literally Fabric / Whiteboard
##
class WB.Core
    constructor: (@id, @callback) ->
        @canvas = @_createCanvas @id
        @_resizeCanvas $(window).outerWidth(), $(window).outerHeight()

        @callback @, @canvas

    _createCanvas: (id) ->
        new fabric.Canvas id

    _resizeCanvas: (width, height) ->
        @canvas.setHeight height
        @canvas.setWidth width

    setTool: (type) ->
        @tool = type
        switch @tool
            when 'pencil'
                @canvas.isDrawingMode = true
            else
                @canvas.isDrawingMode = false

    getSnapshot: ->
        JSON.stringify @canvas

    loadSnapshot: (data) ->
        @canvas.loadFromJSON data, @canvas.renderAll.bind @canvas

Whiteboard = new WB.Core 'js-whiteboard', WB.Collaborate

##
## Toolbelt Events
##
(($) ->
    $('li[data-tool]').click ->
        $(@).parent().find('li').removeClass 'active'
        $(@).toggleClass 'active'
        Whiteboard.setTool $(@).data 'tool'

)(jQuery)