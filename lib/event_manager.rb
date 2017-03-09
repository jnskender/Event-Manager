require 'csv'
require 'sunlight/congress'
require 'erb'
require 'date'

Sunlight::Congress.api_key = 'e179a6973728c4dd3fb1204283aaccb5'

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
    phone_number.gsub!(/\D/, '')

    if phone_number.length == 10
        return phone_number
    elsif phone_number.length == 11 && phone_number[0] == 1
        return phone_number = phone_number[1..10]
    else
        return phone_number = '0000000000'
    end
end

def legislators_by_zipcode(zipcode)
    Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
    Dir.mkdir('output') unless Dir.exist?('output')

    filename = "output/thanks_#{id}.html"

    File.open(filename, 'w') do |file|
        file.puts form_letter
    end
end

def find_peak_hour(date)
  hours = Hash.new(0)
  hours[date.strftime('%l %p')] += 1
  peak_hour = hours.max_by{|k,v| v}[0]
  peak_hour
end

puts 'Event Manager Initialized!'

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol
template_letter = File.read 'form_letter.erb'
erb_template = ERB.new template_letter

hours = Hash.new(0)
days = Hash.new(0)

contents.each do |row|
    id = row[0]
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])
    phone_number = clean_phone_number(row[:homephone])
    legislators = legislators_by_zipcode(zipcode)

    regtime = DateTime.strptime(row[:regdate], '%m/%d/%y %H:%M')
    hours[regtime.strftime('%l %p')] += 1
    days[regtime.strftime('%A')] += 1
        #form_letter = erb_template.result(binding)
        #save_thank_you_letters(id, form_letter)
end
    peak_hour = hours.max_by{|k,v| v}[0] #Find what time most registrations occurred
    peak_day = days.max_by{|k,v| v}[0]
    puts "#{peak_hour} #{peak_day}"
