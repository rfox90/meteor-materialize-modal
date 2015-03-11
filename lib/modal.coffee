
DEBUG = true

class MaterializeModalClass

  defaults:
    title: 'Message'
    message: ''
    body_template_data: {}
    type: 'message'
    closeLabel: null
    submitLabel: 'OK'

  options: {}


  constructor: ->
    @errorMessage = new ReactiveVar(null)


  reset: ->
    @options = @defaults
    @callback = null
    @errorMessage.set(null)
    

  open: ->
    @tmpl = Blaze.renderWithData(Template.materializeModal, @options, document.body)
    

  close: ->
    $('#materializeModal').closeModal
      complete: =>
        Blaze.remove(@tmpl)
    @reset()


  modalReady: ->
    console.log("materializeModal is open")


  message: (@options = {}) ->
    _.defaults @options, 
      message: 'You need to pass a message to materialize modal!'
      title: 'Message'
    , @defaults

    @open()


  alert: (@options = {}) ->
    _.defaults options, 
      type: 'alert'
      message: 'Alert'
      title: 'Alert'
      label: "Alert"
      bodyTemplate: "materializeModalAlert"
      @defaults

    @open()


  error: (@options = {}) ->
    _.defaults options, 
      type: 'error'
      message: 'Error'
      title: 'Error'
      label: "Error"
      bodyTemplate: "materializeModalError"
    , @defaults
    
    @open()


  confirm: (@options = {}) ->  
    _.defaults @options, 
      type: 'confirm'
      message: 'Message'
      title: 'Confirm'
      closeLabel: 'Cancel'
    , @defaults

    @open()


  prompt: (@options = {}) -> #(message, callback, title = 'Prompt', okText = 'Submit', placeholder = "Enter something ...") ->
    _.defaults @options, 
      type: 'prompt'
      message: 'Feedback?'
      title: 'Prompt'
      bodyTemplate: 'materializeModalPrompt'
      closeLabel: 'Cancel'
      submitLabel: 'Submit'
      placeholder: "Type something here"
    , @defaults

    @open()


  addValueToObjFromDotString: (obj, dotString, value) ->
    path = dotString.split(".")
    tmp = obj
    lastPart = path.pop()
    for part in path
      # loop through each part of the path adding to obj
      if not tmp[part]?
        tmp[part] = {}
      tmp = tmp[part]
    if lastPart?
      tmp[lastPart] = value


  fromForm: (form) ->
    result = {}
    form = $(form)
    for key in form.serializeArray() # This Works do not change!!!
      @addValueToObjFromDotString(result, key.name, key.value)
    # Override the result with the boolean values of checkboxes, if any
    for check in form.find "input:checkbox"
      if $(check).prop('name')
        result[$(check).prop('name')] = $(check).prop 'checked'
    result



  doCallback: (yesNo, event = null) ->
    switch @options.type
      when 'prompt'
        returnVal = $('#prompt-input').val()
      when 'select'
        returnVal = $('select option:selected')
      when 'form'
        returnVal = @fromForm(event.target)
      else
        returnVal = null

    if @options.callback?
      @options.callback(yesNo, returnVal, event)


###
  


  status: (message, callback, title = 'Status', cancelText = 'Cancel') ->
    @_setData message, title, "materializeModalstatus",
      message: message
    @callback = callback
    @set("submitLabel", cancelText)
    @_show()

  updateProgressMessage: (message) ->
    if DEBUG
      console.log("updateProgressMessage", $("#progressMessage").html(), message)
    if $("#progressMessage").html()?
      $("#progressMessage").fadeOut 400, ->
        $("#progressMessage").html(message)
        $("#progressMessage").fadeIn(400)
    else
      @set("message", message)


  formWithOptions: (options, data, callback) ->
    if options?.template?
      _.defaults options,
        title: "Edit Record"
        submitText: 'Submit'
        cancelText: 'Cancel'
      if not data
        data = {}
      @_setData('', options.title, options.template, data)
      @type = "form"
      @callback = callback
      @set("closeLabel", options.cancelText)
      @set("submitLabel", options.submitText)
      if options.smallForm
        @set("size", 'modal-sm')
        @set("btnSize", 'btn-sm')
      $(".has-error").removeClass('has-error')
      @_show()

  form: (templateName, data, callback, title = "Edit Record", okText = 'Submit') ->
    if DEBUG
      console.log("form", templateName, data, title)
    @_setData('', title, templateName, data)
    @type = "form"
    @callback = callback
    @set("closeLabel", "Cancel")
    @set("submitLabel", okText)
    @_show()

  smallForm: (templateName, data, callback, title = "Edit Record", okText = 'Submit') ->
    #console.log("form", templateName, data)
    @_setData('', title, templateName, data)
    @type = "form"
    @callback = callback
    @set("closeLabel", "Cancel")
    @set("submitLabel", okText)
    @set("size", 'modal-sm')
    @set("btnSize", 'btn-sm')
    @_show()

###


MaterializeModal = new MaterializeModalClass()



Template.materializeModal.created = ->
  console.log("materializeModal created") if DEBUG


Template.materializeModal.rendered = ->
  console.log("materializeModal rendered", @data.title)  if DEBUG
  $('#materializeModal').openModal
    ready: MaterializeModal.modalReady()

#    Meteor.defer ->
#        $('#prompt-input')?.focus()


Template.materializeModal.destroyed = ->
  console.log("materializeModal destroyed") if DEBUG


Template.materializeModal.helpers

  template: ->
    if @bodyTemplate? and Template[@bodyTemplate]?
      console.log("render template", @bodyTemplate) if DEBUG
      @bodyTemplate

  templateData: ->
    @

  isForm: ->
    MaterializeModal.type is 'form'

  errorMessage: ->
    MaterializeModal.errorMessage.get()

  icon: ->
    console.log("icon: type", @type) if DEBUG
    switch @type
      when 'alert'
        'mdi-alert-warning'
      when 'error'
        'mdi-alert-error'



Template.materializeModal.events
  "click #closeButton": (e, tmpl) ->
    MaterializeModal.doCallback(false, e)
    MaterializeModal.close()


  "click #submitButton": (e, tmpl) ->
    MaterializeModal.doCallback(true, e)
    MaterializeModal.close()


  'submit #modalDialogForm': (e, tmpl) ->
    e.preventDefault()
    try
      MaterializeModal.doCallback(true, e)
      MaterializeModal.close()
    catch err
      MaterializeModal.errorMessage.set(err.reason)
      


Template.materializeModalstatus.helpers
  progressMessage: ->
    #....
