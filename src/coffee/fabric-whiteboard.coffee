window.WB = window.WB ? {}

##
## TogetherJS Events
##
WB.Collaborate = (wb, canvas) ->
    @TJS = TogetherJS
    @client = []
    @isDrawing = false

    # Bind Whiteboard events (OUT)
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

        @modifyObject = (data) =>
            TogetherJS.send
                type: 'objectModified'
                id: canvas.getObjects().indexOf data.target
                properties:
                    angle: data.target.getAngle()
                    left: data.target.getLeft()
                    top: data.target.getTop()
                    scale: data.target.getScaleX()

        canvas.on
            'object:moving': @modifyObject,
            'object:scaling': @modifyObject,
            'object:resizing': @modifyObject,
            'object:rotating': @modifyObject

        canvas.on 'selection:created', (data) =>
            # @TODO Handle group movements

    @TJS.on 'close', =>
        canvas.off { 'mouse:down', 'mouse:move', 'mouse:up', 'object:moving', 'object:scaling', 'object:resizing', 'object:rotating' }

    # Bind hub events (IN)
    @TJS.hub.on 'togetherjs.hello', =>
        TogetherJS.send
            type: 'init'
            data: wb.getSnapshot()

    @TJS.hub.on 'init', (snapshot) =>
        wb.loadSnapshot snapshot.data

    @TJS.hub.on 'drawStart', (data) =>
        @client[data.clientId] ?= new fabric['PencilBrush'](canvas)
        @client[data.clientId].onMouseDown data.point

    @TJS.hub.on 'drawContinue', (data) =>
        @client[data.clientId].onMouseMove data.point

    @TJS.hub.on 'drawEnd', (data) =>
        @client[data.clientId].onMouseUp()

    @TJS.hub.on 'objectModified', (data) =>
        prop = data.properties
        canvas.item(data.id).setAngle(prop.angle).setLeft(prop.left).setTop(prop.top).scale(prop.scale).setCoords()
        canvas.renderAll()

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