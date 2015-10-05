﻿window.kaleido = kaleido = {}

Monitors = []

kaleido.init = () ->
    $ "#add-monitor-submit"
        .click (e) -> addMonitor
            name: $('#add-monitor-form-name').val()
            url: $('#add-monitor-form-url').val()
            selector: $('#add-monitor-form-selector').val()

addMonitor = (monitor) ->
    Monitors.push monitor
    renderMonitor monitor
    syncMonitor monitor
    do saveMonitors
    alertMessage "Monitor Added Successfully!", 'success'
    
renderMonitor = (monitor) ->
    if monitor.rendered then return else monitor.rendered = on
    HTMLstr = """
        <div id="monitor-#{monitor.name}">#{monitor.lastSync?.result}</div>
    """
    $ HTMLstr
        .appendTo $ "#monitor-container"

updateRenderedMonitor = (monitor) ->
    $ "#monitor-#{monitor.name}"
        .text monitor.lastSync?.result

syncMonitor = (monitor, cb) ->
    $.get monitor.url, (data, status, xhr) ->
        data = $ monitor.selector, data
        data = if monitor.process
            $data = data
            eval monitor.process
        else
            data.text()
        monitor.lastSync =
            time: _.now()
            result: data
        updateRenderedMonitor monitor
        cb?()

saveMonitors = (cb=_.identity) ->
    MonitorsToSave = Monitors.map (monitor) ->
        name: monitor.name
        url: monitor.url
        selector: monitor.selector
        lastSync:
            time: monitor.lastSync?.time
            result: monitor.lastSync?.result

    Windows.Storage.ApplicationData.current.roamingFolder
        .createFileAsync "Monitors.json", Windows.Storage.CreationCollisionOption.replaceExistring
        .then (file) ->
            Windows.Storage.FileIO.writeTextAsync file, JSON.stringify MonitorsToSave
        .done cb

alertMessage = (msg, type="info") ->
    HTMLstr = """
    <div id="alerter" class="alert alert-dismissible alert-#{type} fade" role="alert">
        <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
        <span id="alerter-message">#{msg}</span>
    </div>
    """
    $ HTMLstr
        .appendTo $ '#alerter'

# Helpers

COLORS = ["AliceBlue","AntiqueWhite","Aqua","Aquamarine","Azure","Beige","Bisque","Black","BlanchedAlmond","Blue","BlueViolet","Brown","BurlyWood","CadetBlue","Chartreuse","Chocolate","Coral","CornflowerBlue","Cornsilk","Crimson","Cyan","DarkBlue","DarkCyan","DarkGoldenRod","DarkGray","DarkGreen","DarkKhaki","DarkMagenta","DarkOliveGreen","DarkOrange","DarkOrchid","DarkRed","DarkSalmon","DarkSeaGreen","DarkSlateBlue","DarkSlateGray","DarkTurquoise","DarkViolet","DeepPink","DeepSkyBlue","DimGray","DodgerBlue","FireBrick","FloralWhite","ForestGreen","Fuchsia","Gainsboro","GhostWhite","Gold","GoldenRod","Gray","Green","GreenYellow","HoneyDew","HotPink","IndianRed ","Indigo  ","Ivory","Khaki","Lavender","LavenderBlush","LawnGreen","LemonChiffon","LightBlue","LightCoral","LightCyan","LightGoldenRodYellow","LightGray","LightGreen","LightPink","LightSalmon","LightSeaGreen","LightSkyBlue","LightSlateGray","LightSteelBlue","LightYellow","Lime","LimeGreen","Linen","Magenta","Maroon","MediumAquaMarine","MediumBlue","MediumOrchid","MediumPurple","MediumSeaGreen","MediumSlateBlue","MediumSpringGreen","MediumTurquoise","MediumVioletRed","MidnightBlue","MintCream","MistyRose","Moccasin","NavajoWhite","Navy","OldLace","Olive","OliveDrab","Orange","OrangeRed","Orchid","PaleGoldenRod","PaleGreen","PaleTurquoise","PaleVioletRed","PapayaWhip","PeachPuff","Peru","Pink","Plum","PowderBlue","Purple","RebeccaPurple","Red","RosyBrown","RoyalBlue","SaddleBrown","Salmon","SandyBrown","SeaGreen","SeaShell","Sienna","Silver","SkyBlue","SlateBlue","SlateGray","Snow","SpringGreen","SteelBlue","Tan","Teal","Thistle","Tomato","Turquoise","Violet","Wheat","White","WhiteSmoke","Yellow","YellowGreen"]

getRandomColor = () ->
    _.sample COLORS
