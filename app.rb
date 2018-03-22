require "rubygems"
require "sinatra/base"
require "json"
require "sendgrid-ruby"
include SendGrid

class App < Sinatra::Base

	before do
		content_type :json
     	headers 'Access-Control-Allow-Origin': '*',
	            'Access-Control-Allow-Methods': ['OPTIONS', 'GET', 'POST'],
	            'Access-Control-Allow-Headers': 'Content-Type'
	end

	set :protection, except: :http_origin

	helpers do

 	 	def send_email(params, user)

			# create variables
			from = Email.new(email: params["email"], name: params["name"])
			to = Email.new(email: user.email, name: user.name)
			subject = params["subject"]
			content = Content.new(type: 'text/html', value: params["message"])

			# create email
			mail = Mail.new(from, subject, to, content)

			# instance sendgrid
			sendgrid = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])

			# send email
			response = sendgrid.client.mail._('send').post(request_body: mail.to_json)
			response.body

    options "/user" do
    	200
    end


    post "/user" do
    	content_type :json

    	params = JSON.parse(request.body.read)

    	user = User.first(uuid: params["uuid"])
    	unless user
			halt 400, "Bad Request"
		end

		if user and params.keys.length == 5

			status = send_email(params, user)

			if status[0]['status'] != 'sent'
				return {message: "The message could not be sent"}.to_json
			else
				halt 200, {message: "Message Sent!"}.to_json
			end

		else
			halt 400, "Bad Request"
		end


    end

	post "/register" do
		user = User.first(email: params[:email])
		if user
			"The user is already registered"
		else
			@user = User.create(name: params[:name], email: params[:email], url: params[:url], uuid: UUID.generate)
			"Token: #{@user.uuid} "
		end
	end





end
