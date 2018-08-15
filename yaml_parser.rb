require 'YAML'

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
      File.open("tmp/metadata/#{split_file}_#{language}.txt", 'w') do |f|
        f.puts "Name: #{yaml_data["interviewee"]["name"]}"
        f.puts "Birthplace: #{yaml_data["interviewee"]["birthplace"]}"
        f.puts "Nationality: #{yaml_data["interviewee"]["nationality"]}"
        f.puts "Gender: #{yaml_data["interviewee"]["gender"]}"
        #f.puts "Name: #{yaml_data["interviewee"]["name"]}"
        #f.puts "Name: #{yaml_data["interviewee"]["name"]}"
        #f.puts "Name: #{yaml_data["interviewee"]["name"]}"
        #f.puts "Name: #{yaml_data["interviewee"]["name"]}"
        #f.puts "Name: #{yaml_data["interviewee"]["name"]}"
        #f.puts "Name: #{yaml_data["interviewee"]["name"]}"
        #f.puts "Name: #{yaml_data["interviewee"]["name"]}"
        #f.puts "Name: #{yaml_data["interviewee"]["name"]}"
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

parse_metadata(get_files("data/*.yml"))
parse_transcripts(get_files("data/*.yml"))
parse_translations(get_files("data/*.yml"))
