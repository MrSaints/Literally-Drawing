window.WB = window.WB ? {}

WB.bindEvents = (wb, stage, background) ->
    background.on 'mousedown touchstart', (event) =>
        wb.begin stage.getPointerPosition().x, stage.getPointerPosition().y

    stage.on 'contentMousemove contentTouchmove', =>
        wb.continue stage.getPointerPosition().x, stage.getPointerPosition().y

    stage.on 'contentMouseup contentTouchend', =>
        wb.end stage.getPointerPosition().x, stage.getPointerPosition().y

WB.bindDrawingEvents = (wb, object) ->
    object.on 'mouseover mouseenter', =>
        document.body.style.cursor = 'pointer'

    object.on 'mouseout mouseleave', =>
        document.body.style.cursor = 'default'

class WB.Core
    constructor: ->
        @lastAction = undefined
        @isDrawing = false
        @tool = new WB.Pencil

        @stage = @_createStage()
        @layer = @_createLayer()
        @background = @_createBackground @stage.getWidth(), @stage.getHeight()

        @layer.add @background
        @stage.add @layer

        WB.bindEvents this, @stage, @background

    begin: (x, y) ->
        @tool.begin x, y, this
        @isDrawing = true

    continue: (x, y) ->
        return false if !@isDrawing
        @tool.continue x, y, this

    end: (x, y) ->
        return false if !@isDrawing
        @tool.end x, y, this
        @isDrawing = false

    _createStage: ->
        new Kinetic.Stage
            container: 'js-whiteboard'
            width: $(window).width()
            height: $(window).height()

    _createLayer: ->
        new Kinetic.Layer

    _createBackground: (width, height) ->
        new Kinetic.Rect
            width: width
            height: height

    undo: ->
        @lastAction = @layer.getChildren()[@layer.getChildren().length - 1]
        @lastAction.remove()

    redo: ->
        @layer.add @lastAction if @lastAction?
        @lastAction = undefined

class WB.Tool
    begin: (x, y, wb) ->
    continue: (x, y, wb) ->
    end: (x, y, wb) ->

class WB.Pencil extends WB.Tool
    begin: (x, y, wb) ->
        @instance = @_init()
        @instance.setPoints [{x: x, y: y}]
        wb.layer.add @instance

    continue: (x, y, wb) ->
        @instance.addPoint { x: x, y: y }
        wb.layer.batchDraw()

    end: (x, y, wb) ->
        WB.bindDrawingEvents wb, @instance
        @instance = undefined

    _init: ->
        new Kinetic.Spline
            stroke: 'black'
            lineCap: 'round'
            draggable: true

Whiteboard = new WB.Core