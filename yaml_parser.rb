require 'YAML'

def get_files(filepath)
  # Create array of YAML files from data directory
  Dir[filepath]
end

# Method to strip out cruft from filenames for naming VTT files
def strip_filenames(file)
  file.split('/')[1].split('.')[0]
end

def parse_metadata(files)
  # Metadata about interview for different file
  #puts "Metadata:"
  #puts thing["interviewee"]
  #puts "Language of transcript:"
  #puts yaml_data["recording"]["transcript"]["language"]
end

def parse_translations(files)
end

def parse_transcripts(files)
  files.each do |yaml_file|
    yaml_data = YAML.load_file(yaml_file)

    split_file = strip_filenames(yaml_file)
    
    # Open file and write header
    File.open("tmp/#{split_file}.vtt", 'w') { |file| file.puts("WEBVTT") }
    # Newline
    File.open("tmp/#{split_file}.vtt", 'a') { |file| file.puts("") }

    File.open("tmp/#{split_file}.vtt", 'a') do |f|
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
    end
  end
end

parse_transcripts(get_files("data/*.yml"))
