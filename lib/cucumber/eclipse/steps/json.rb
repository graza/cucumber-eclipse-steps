require "cucumber/eclipse/steps/version"
require 'cucumber/formatter/progress'
require 'cucumber/step_definition_light'
require 'multi_json'

module Cucumber
  module Eclipse
    module Steps
      class Json < Cucumber::Formatter::Progress
        include Cucumber::Formatter::Console
  
        class StepDefKey < Cucumber::StepDefinitionLight
          attr_accessor :mean_duration, :status
        end
  
        def initialize(runtime, path_or_io, options)
          @runtime = runtime
          @io = ensure_io(path_or_io, "usage")
          @options = options
          @stepdef_to_match = Hash.new{|h,stepdef_key| h[stepdef_key] = []}
        end
  
        def before_features(features)
          print_profile_information
        end
  
        def before_step(step)
          @step = step
          @start_time = Time.now
        end
  
        def before_step_result(*args)
          @duration = Time.now - @start_time
        end
  
        def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line)
          step_definition = step_match.step_definition
          unless step_definition.nil? # nil if it's from a scenario outline
            stepdef_key = StepDefKey.new(step_definition.regexp_source, step_definition.file_colon_line)
  
            @stepdef_to_match[stepdef_key] << {
              :keyword => keyword,
              :step_match => step_match,
              :status => status,
              :file_colon_line => @step.file_colon_line,
              :duration => @duration
            }
          end
          super
        end
  
        def print_summary(features)
          add_unused_stepdefs
          aggregate_info
  
          if @options[:dry_run]
            keys = @stepdef_to_match.keys.sort {|a,b| a.regexp_source <=> b.regexp_source}
          else
            keys = @stepdef_to_match.keys.sort {|a,b| a.mean_duration <=> b.mean_duration}.reverse
          end
  
          keys.each do |stepdef_key|
            print_step_definition(stepdef_key)
  
            if @stepdef_to_match[stepdef_key].any?
              print_steps(stepdef_key)
            else
              @io.puts("  " + format_string("NOT MATCHED BY ANY STEPS", :failed))
            end
          end
          @io.puts
          super
        end
  
        def print_step_definition(stepdef_key)
          @io.write(MultiJson.dump({
              :mean_duration => stepdef_key.mean_duration,
              :regexp_source => stepdef_key.regexp_source,
              :status => stepdef_key.status,
              :file_colon_line => stepdef_key.file_colon_line
          }, :pretty => true))
          @io.puts
        end
  
        def print_steps(stepdef_key)
          @io.write(MultiJson.dump(@stepdef_to_match[stepdef_key], :pretty => true))
        end
  
        def add_unused_stepdefs
          @runtime.unmatched_step_definitions.each do |step_definition|
            stepdef_key = StepDefKey.new(step_definition.regexp_source, step_definition.file_colon_line)
            @stepdef_to_match[stepdef_key] = []
          end
        end
      end
    end
  end
end
