window.ResizeLayoutContainer = (params) ->
  params = if params then params else {}
  parent = if params.container then params.container else "#streams_container"
  element = if params.element then params.element else ".OT_video-container"
  parent$ = $(parent)
  parent$.css( {'padding-top': "0"} )
  videoCount = parent$.find( element ).length
  width = parent$.innerWidth()
  height = parent$.innerHeight()

  # start with first row
  rows = 1
  cols = Math.ceil( videoCount*1.0/rows )
  eWidth = 0
  eHeight = 0

  # Check row limitation
  while( true )
    cols = Math.ceil( videoCount*1.0/rows )
    nWidth = width*1.0/cols
    nHeight = (nWidth/4.0)*3.0
    
    testHeight = height*1.0/rows
    testWidth = height*(4.0/3.0)

    # nWidth based on rows instead of columns
    if (nHeight > testHeight && (rows*nHeight) > height) or ( ( cols*nWidth > width ) && ( nWidth > testWidth ) )
      nHeight = testHeight
      nWidth = testWidth

    if eWidth != 0 and nWidth <= eWidth
      rows -= 1
      cols = Math.ceil( videoCount*1.0/rows )
      console.log "rows: #{rows}, cols: #{cols} eWidth: #{eWidth}, nWidth: #{nWidth}"
      break

    eWidth = nWidth
    eHeight = nHeight
    rows += 1

  if( eHeight*rows > height )
    console.log "Height is limiting factor"
    eWidth = Math.floor( (1.0*height/rows) * (4.0/3) )
  else
    eWidth = Math.floor( (eHeight*4.0)/3.0 )
    console.log "resized is: #{eWidth}"

  # recalculate row/height because new width/height could have pushed video into the same line
  cols = Math.floor( width*1.0 / eWidth )
  rows = Math.ceil( videoCount*1.0 / cols )
  spacing = Math.floor( (height - (eWidth*3/4.0*rows) )/2 )
  console.log "rows: #{rows}, cols: #{cols} spacing: #{spacing}"
  parent$.css( {'padding-top': spacing} )

  parent$.find( element ).each (k,e)->
    $($(e).parent()).width(eWidth)
    $($(e).parent()).height(eWidth*3/4)
