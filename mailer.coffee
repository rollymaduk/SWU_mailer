class Rp_SWU_Mailer
  constructor:()->
    Meteor.startup ->
      try
        check(Meteor.settings.public.Swu.templates,Object)
        check(Meteor.settings.public.Swu.url,String)
      catch err
        throw new Meteor.Error(err.id,err.message)


  createMailItem:(name,email,data)->
    try
      template=Meteor.settings.public.Swu.templates[name]
      check(template,String)
      check(email,String)
      check(data,Object)
      email_id:template,recipient:{address:email},email_data:data
    catch err
      throw new Meteor.Error(err.id,err.message)

  send:(emails,callback)->
    if callback
      Meteor.call 'rp_swu_send',emails,(err,res)->
        callback err,res
    else
      Meteor.call 'rp_swu_send',emails


if Meteor.isClient
  class Rp_SWU_Mailer_Client extends Rp_SWU_Mailer

  Rp_swu_mailer=new Rp_SWU_Mailer_Client()

if Meteor.isServer
  class Rp_SWU_Mailer_Server extends Rp_SWU_Mailer
    constructor:()->
      Meteor.startup ->
        try
          check(Meteor.settings.Swu.auth,String)
        catch err
          throw new Meteor.Error err.number,err.message

      _url="#{Meteor.settings.public.Swu.url}/batch"
      _auth=Meteor.settings.Swu.auth
      _path="/api/v1/send"
      _method='POST'

      Meteor.methods
        rp_swu_send:(emails)->
          @unblock()
          try
            check(emails,[{email_id:String,recipient:{address:String},email_data:Object}])
            data_obj=({path:_path,method:_method,body:email} for email in emails)
            HTTP.post(_url,{data:data_obj,auth:_auth})
          catch err
            throw new Meteor.Error '1101',err.message

  Rp_swu_mailer=new Rp_SWU_Mailer_Server()





