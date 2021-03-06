require 'gm_support'

class Sorcery
  def initialize(file)
    @file = file
  end

  # Runs ImageMagick's 'mogrify'.
  # See http://www.imagemagick.org/script/mogrify.php
  #
 def manipulate!(args={})
    tokens  = ["mogrify"]
    tokens << convert_to_arguments(args) if args
    tokens << " '#{@file}#{"[#{args[:layer].to_s}]" if args[:layer]}'"
    tokens  = convert_to_command(tokens)
    success = run(tokens)[1]
    success
  end

  # Runs ImageMagick's 'convert'.
  # See http://www.imagemagick.org/script/convert.php
  #
  def convert(output, args={})
    tokens  = ["convert"]
    tokens << convert_to_arguments(args) if args
    tokens << " '#{@file}#{"[#{args[:layer].to_s}]" if args[:layer]}'"
    tokens << " #{output}"
    tokens  = convert_to_command(tokens)
    success = run(tokens)[1]
    success
  end

  # Runs ImageMagick's 'identify'.
  # See http://www.imagemagick.org/script/identify.php
  #
  def identify(args={})
    tokens = ["identify"]
    tokens << convert_to_arguments(args) if args
    tokens << " '#{@file}#{"[#{args[:layer].to_s}]" if args[:layer]}'"
    tokens  = convert_to_command(tokens)
    output  = run(tokens)[0]
    output
  end

  # Return the x and y dimensions of an image as a hash.
  #
  def dimensions
    dimensions = identify(:layer => 0, :format => "%wx%h").chomp.split("x")
    { :x => dimensions[0],
      :y => dimensions[1] }
  end

  # Runs ImageMagick's 'montage'.
  # See http://www.imagemagick.org/script/montage.php
  #
  def montage(sources, args={})
    tokens = ["montage"]
    tokens << convert_to_arguments(args) if args
    sources.each {|source| tokens << " '#{source}'" }
    tokens << " '#{@file}'"
    tokens  = convert_to_command(tokens)
    success = run(tokens)[1]
  end

  private

  def convert_to_command(tokens)
    tokens[0] = prefix(tokens[0]) if respond_to? :prefix
    tokens.flatten.join("")
  end

  def convert_to_arguments(args)
    args.reject {|k, v| k == :layer }.map {|k, v| " -#{k} '#{v}'"}
  end

  def run(cmds)
    output = IO.popen(cmds.to_s) {|o| o.read }
    success = $?.exitstatus == 0 ? true : false
    [output,success]
  end
end
