require 'clicksign'

Clicksign.configure do |config|
  config.token = ENV['CLICKSIGN_TOKEN']
  config.endpoint = 'https://api.clicksign-demo.com/'
end

def new_file(prefix = '')
  name = "./txt/#{prefix}"+ Time.now.strftime("%F-%H-%M-%S") + ".txt"
  File.open(name, 'w') {|f| f. write "a.\n" }
  name
end

def create(filename = new_file("without-list-"))
  # Create a document
  doc = Clicksign::Document.create(File.new(filename))

  # Get Key identification
  key = doc['document']['key']

  signers = [ { email: 'mauricio.vieira+john.doe@mauriciovieira.net', act: 'sign' },
    { email: 'mauricio.vieira+jane.barbera@mauriciovieira.net', act: 'sign' } ,
    { email: 'mauricio.vieira+mat.smith@mauriciovieira.net', act: 'witness'} ]

  # Create a new signature list
  result = Clicksign::Document.create_list(key, signers, false)
  key
end

def create_with_list(filename = new_file("with-list-"))
  signers = [ { email: 'mauricio.vieira+jo@mauriciovieira.net', act: 'sign' },
    { email: 'mauricio.vieira+ja@mauriciovieira.net', act: 'sign' } ,
    { email: 'mauricio.vieira+ma@mauriciovieira.net', act: 'witness'} ]
  message = "Please signupnas"
  skip_email = false

  # Create a document
  doc = Clicksign::Document.create(File.new(filename),
    signers: signers, message: message, skip_email: skip_email)

  # Get Key identification
  doc['document']['key']
end

def resend key
  # Resend signature request to somebody
  message = "A document is waiting for you. Please sign."
  doc = Clicksign::Document.resend(key, 'mauricio.vieira+mat.smith@mauriciovieira.net', message)
  pretty_print doc
end

def all
  docs = Clicksign::Document.all
  docs.each do |doc|
    pretty_print doc
  end
end

def find key
  doc = Clicksign::Document.find key
  pretty_print doc
end

def pretty_print doc
  key = doc['document']['key']
  status = doc['document']['status']
  original_name = doc['document']['original_name']
  puts "#{key} - #{status} - #{original_name}"
end

def cancel key
  doc = Clicksign::Document.cancel key
  pretty_print doc
end

key = create
puts "\n#{key} created"

puts "\nResend"
resend key

puts "\nAll"
all

key = create_with_list "pdf/a.pdf"
puts "\n#{key} created"

find key

cancel key
