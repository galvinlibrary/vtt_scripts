require 'YAML'
require 'CSV'

# Create array of YAML files from data directory
def get_files(filepath)
  Dir[filepath]
end

# Method to strip out cruft from filenames for naming VTT files
def strip_filenames(file)
  file.split('/')[1].split('.')[0]
end

# Interview metadata into txt file?
def parse_metadata(files)
  # Open file and write headers
  CSV.open("tmp/metadata/metadata.csv", "wb") do |csv|
    csv << [
      "identifier",
      "legacy_identifier",
      "name",
      "birthplace",
      "nationality",
      "gender",
      "locations - invasion",
      "locations - internments",
      "locations - liberation - date",
      "locations - liberation - location",
      "locations - liberation - by",
      "date", "recording location",
      "recording languages",
      "recording duration",
      "recording spools",
      "audio - file",
      "audo - mime-type",
      "credits - who, role",
      "commentary - text",
      "commentary - attribution"
    ]
  end
  # Iterate through each file and write metadata to a row in CSV
  files.each do |yaml_file|
    yaml_data = YAML.load_file(yaml_file)

    split_file = strip_filenames(yaml_file)
    # Make sure the file has data in it
    if yaml_data
      CSV.open("tmp/metadata/metadata.csv", "ab") do |csv|
        csv << [
         "#{yaml_data["interviewee"]["identifier"]}",
         "#{yaml_data["interviewee"]["legacy_identifier"]}",
         "#{yaml_data["interviewee"]["name"]}",
         "#{yaml_data["interviewee"]["birthplace"]}",
         "#{yaml_data["interviewee"]["nationality"]}",
         "#{yaml_data["interviewee"]["gender"]}",
         "#{yaml_data["interviewee"]["locations"]["invasion"]}",
         "#{yaml_data["interviewee"]["locations"]["internments"].join(", ")}",
         "#{yaml_data["interviewee"]["locations"]["liberation"]["date"]}",
         "#{yaml_data["interviewee"]["locations"]["liberation"]["location"]}",
         "#{yaml_data["interviewee"]["locations"]["liberation"]["by"]}",
         "#{yaml_data["recording"]["date"]}",
         "#{yaml_data["recording"]["location"]}",
         "#{yaml_data["recording"]["languages"].join(", ")}",
         "#{yaml_data["recording"]["duration"]}",
         "#{yaml_data["recording"]["spools"].join(", ")}",
         "#{yaml_data["recording"]["audio"]["file"]}",
         "#{yaml_data["recording"]["audio"]["mime-type"]}",
         "#{yaml_data["recording"]["credits"].map {|hash| hash.values}.join(", ")}",
         "#{yaml_data["recording"]["commentary"]["text"]}",
         "#{yaml_data["recording"]["commentary"]["attribution"]}"
       ]
      end
    else
      puts "#{split_file} has no data. Check to make sure it has content!"
    end
  end
end

def parse_translations(files)
  files.each do |yaml_file|
    yaml_data = YAML.load_file(yaml_file)

    split_file = strip_filenames(yaml_file)

    # Make sure the file has data in it
    if yaml_data
      if yaml_data["recording"]["translation"]
        language = yaml_data["recording"]["translation"]["language"]
      else
        language = "none"
      end

      # Open file and write header
      File.open("tmp/translations/#{split_file}_#{language}.vtt", 'w') do |f|
        f.puts("WEBVTT")
        f.puts("")
        if yaml_data["recording"]["translation"].class == NilClass
          f.puts "#{split_file} has no translation"
        else
          yaml_data["recording"]["translation"]["interview"].each do |y|

            # Write start and end timestamp
            start_to_end = "#{y["start"]["mark"]} --> #{y["end"]["mark"]}"
            f.puts("#{start_to_end}")

            # Write speaker and text of translation
            speaker_content = "#{y["who"]}: #{y["u"]}"
            f.puts("#{speaker_content}")
            # Newline
            f.puts("")
          end
          f.close
        end
      end
    else
      puts "#{split_file} has no data. Check to make sure it has content!"
    end
  end
end

def parse_transcripts(files)
  files.each do |yaml_file|
    yaml_data = YAML.load_file(yaml_file)

    split_file = strip_filenames(yaml_file)

    # Make sure the file has data in it
    if yaml_data
      if yaml_data["recording"]["transcript"]
        language = yaml_data["recording"]["transcript"]["language"]
      else
        language = "none"
      end
      # Open file and write header
      File.open("tmp/transcripts/#{split_file}_#{language}.vtt", 'w') do |f|
        f.puts("WEBVTT")
        f.puts("")
        if yaml_data["recording"]["transcript"].class == NilClass
          f.puts "#{split_file} has no transcript"
        else
          # Iterate through each interview element
          yaml_data["recording"]["transcript"]["interview"].each do |y|

            # Write start and end timestamp
            start_to_end = "#{y["start"]["mark"]} --> #{y["end"]["mark"]}"
            f.puts("#{start_to_end}")

            # Write speaker and text of transcript
            speaker_content = "#{y["who"]}: #{y["u"]}"
            f.puts("#{speaker_content}")
            # Newline
            f.puts("")
          end
          f.close
        end
      end
    else
      puts "#{split_file} has no data. Check to make sure it has content!"
    end
  end
end

# Call all methods. Comment out any that you don't need to speed up the process
parse_metadata(get_files("data/*.yml"))
parse_transcripts(get_files("data/*.yml"))
parse_translations(get_files("data/*.yml"))
