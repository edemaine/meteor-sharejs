###
This code connects a CodeMirror editor to a sharejs document.
It was originally based on
https://github.com/HansPinckaers/shareJS/blob/master/src/client/cm.coffee
which was in turn inspiredfrom the ace editor hook.
Then it was tweaked slightly by mizzao for the meteor-sharejs project,
and finally fixed to handle multiple deltas by Erik Demaine.
###

# Convert CodeMirror deltas into ops understood by share.js
applyToShareJS = (editorDoc, deltas, doc) ->
  # Handle single delta with simpler code
  if deltas.length == 1
    delta = deltas[0]
    pos = editorDoc.indexFromPos delta.from
    if delta.removed.length  # Deleted/replaced line(s) of text
      delLen = delta.removed.length - 1  # count newlines
      for rm in delta.removed
        delLen += rm.length
      doc.del pos, delLen
    if delta.text.length  # Insertion/replacement line(s) of text
      doc.insert pos, delta.text.join '\n'
    return

  # Handle multiple deltas. This is tricky because each delta adjusts the
  # indexing within the document, but all deltas are indexed in terms of
  # the current document, yet we only have the "after" editor document.
  # We use the current sharejs document as a proxy for the current document.
  for delta in deltas
    #console.log delta
    # Compute index for edit's "from" line/ch using current document text.
    text = doc.getText()
    index = 0
    for i in [0...delta.from.line]
      index = 1 + text.indexOf '\n', index
    index += delta.from.ch
    if delta.removed.length  # Deleted/replaced
      delLen = delta.removed.length - 1  # count newlines
      for rm in delta.removed
        delLen += rm.length
      #console.log 'deleting', index, delLen
      doc.del index, delLen if delLen
    if delta.text.length  # Insertion/replacement
      #console.log 'inserting', index, delta.text.join '\\n'
      doc.insert index, delta.text.join '\n'


# Attach a CodeMirror editor to the document. The editor's contents are replaced
# with the document's contents unless keepEditorContents is true. (In which case
# the document's contents are nuked and replaced with the editor's).
window.sharejs.extendDoc 'attach_cm', (editor, keepEditorContents) ->
  unless @provides.text
    throw new Error 'Only text documents can be attached to CodeMirror'

  # When we apply ops from sharejs, CodeMirror emits edit events.
  # We need to ignore those to prevent an infinite typing loop.
  suppress = false

  sharedoc = @
  check = ->
    window.setTimeout ->
        editorText = editor.getValue()
        otText = sharedoc.getText()

        if editorText != otText
          console.error "Text does not match!"
          console.error "editor: #{editorText}"
          console.error "ot:     #{otText}"
          # Replace the editor text with the doc snapshot.
          suppress = true
          editor.setValue sharedoc.getText()
          suppress = false
      , 0

  if keepEditorContents
    @del 0, sharedoc.getText().length
    @insert 0, editor.getValue()
  else
    # Prevent immediate undo from going before initially loaded text.
    undoDepth = editor.getOption 'undoDepth'
    editor.setOption 'undoDepth', 0
    editor.setValue sharedoc.getText()
    editor.setOption 'undoDepth', undoDepth

  check()

  # Listen for edits in CodeMirror.
  editorListener = (ed, change) ->
    return if suppress
    applyToShareJS editor, change, sharedoc
    check()

  editor.on 'changes', editorListener

  @on 'insert', (pos, text) ->
    # All the primitives we need are already in CM's API.
    suppress = true
    editor.replaceRange text, editor.posFromIndex(pos)
    suppress = false
    check()

  @on 'delete', (pos, text) ->
    suppress = true
    from = editor.posFromIndex pos
    to = editor.posFromIndex (pos + text.length)
    editor.replaceRange '', from, to
    suppress = false
    check()

  @detach_cm = ->
    # TODO: can we remove the insert and delete event callbacks?
    editor.off 'changes', editorListener
    delete @detach_cm

  return

