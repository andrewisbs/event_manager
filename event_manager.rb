require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
def legislator_by_zipcode(zip)
civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
begin
    legislators = civic_info.representative_info_by_address(
        address: zip,
        levels: 'country',
        roles: ['legislatorUpperBody', 'legislatorLowerBody']  
        )
    legislators = legislators.officials
    legislator_names = legislators.map(&:name)
    legislators_string = legislator_names.join(", ")
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
end




def clean_zipcode(zipcode)
   zipcode.to_s.rjust(5, '0')[0..4]
end

def save_thank_you_letter(id,form_letter)
    Dir.mkdir('output') unless Dir.exist?('output')

    filename = "output/thanks_#{id}.html"

    File.open(filename, 'w') do |file|
        file.puts form_letter
    end
end 

contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
)

def clean_phone(phone_number)
    phone_number.gsub!("-", "")
    phone_number.gsub!("(", "")
    phone_number.gsub!(")", "")
    phone_number.gsub!(" ","")
    phone_number.gsub!(".","")
    if phone_number.length > 10 && phone_number.length < 12
        phone_number = phone_number[1..11]
    end
    if phone_number.length > 12
        phone_number = "0000000000"
    end
    if phone_number.length < 10
        phone_number = "0000000000"
    end

    fix_phone_number = phone_number.rjust(10, '0')[0..9]
end

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

puts "EventManager Initialized"


contents.each do |row|
    id = row[0]
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])
    legislators = legislator_by_zipcode(zipcode)
    form_letter = erb_template.result(binding)
    save_thank_you_letter(id,form_letter)
    phone_numbers = clean_phone(row[:homephone])
    p phone_numbers
    sub_date = row[:regdate].gsub("/", "-")
    sub_date.gsub!("-0", "-200")
    myDate = Time.strptime(sub_date, "%m-%d-%Y %H:%M")
    p myDate.wday
    
end




    
