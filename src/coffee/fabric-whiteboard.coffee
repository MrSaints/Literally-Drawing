window.WB = window.WB ? {}

##
## TogetherJS Events
##
WB.Collaborate = (wb, canvas) ->
    @tool = new fabric['PencilBrush'](canvas)
    @isDrawing = false

    # Bind Whiteboard events
    TogetherJSConfig_on =
        ready: ->
            canvas.on 'mouse:down', (data) =>
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

        close: ->

    # Bind hub events
    TogetherJS_hub_on = 
        'togetherjs.hello': ->
            TogetherJS.send
                type: 'init'
                data: wb.getSnapshot()

        'init': (snapshot) ->
            wb.loadSnapshot snapshot.data

        'drawStart': (data) ->
            @tool.onMouseDown data.point

        'drawContinue': (data) ->
            @tool.onMouseMove data.point

        'drawEnd': ->
            @tool.onMouseUp()

##
## Literally Fabric / Whiteboard
##
class WB.Core
    constructor: (@id, @callback) ->
        @canvas = @_createCanvas @id
        @_resizeCanvas $(window).outerWidth(), $(window).outerHeight()

        #@canvas.isDrawingMode = true

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