require "cucumber/eclipse/steps/version"
require 'cucumber/formatter/io'
require 'cucumber/step_definition_light'
require 'multi_json'

module Cucumber
  module Eclipse
    module Steps
      class Json
        include Cucumber::Formatter::Io
  
        class StepDefKey < Cucumber::StepDefinitionLight
          attr_accessor :mean_duration, :status
        end
  
        def initialize(runtime, path_or_io, options)
          @runtime = runtime
          @io = ensure_io(path_or_io, "usage")
          @options = options
          @stepdef_to_match = Hash.new{|h,stepdef_key| h[stepdef_key] = []}
        end
  
        #def before_features(features)
        #  print_profile_information
        #end
  
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
              :step_match => step_match.format_args,
              :status => status,
              :file_colon_line => @step.file_colon_line,
              :duration => @duration
            }
          end
        end
  
        def print_summary(features)
          add_unused_stepdefs
          aggregate_info
  
          if @options[:dry_run]
            keys = @stepdef_to_match.keys.sort {|a,b| a.regexp_source <=> b.regexp_source}
          else
            keys = @stepdef_to_match.keys.sort {|a,b| a.mean_duration <=> b.mean_duration}.reverse
          end
  
          step_definitions_array = keys.collect do |stepdef_key|
            h = step_definition_hash(stepdef_key)
  
            if @stepdef_to_match[stepdef_key].any?
              h[:steps] = @stepdef_to_match[stepdef_key]
            end
            h
          end
          @io.write(MultiJson.dump(step_definitions_array, :pretty => true))
          @io.puts
        end
  
        def step_definition_hash(stepdef_key)
          {
            :mean_duration => stepdef_key.mean_duration,
            :regexp_source => stepdef_key.regexp_source,
            :status => stepdef_key.status,
            :file_colon_line => stepdef_key.file_colon_line
          }
        end
  
        def aggregate_info
          @stepdef_to_match.each do |key, steps|
            if steps.empty?
              key.status = :skipped
              key.mean_duration = 0
            else
              key.status = worst_status(steps.map{ |step| step[:status] })
              total_duration = steps.inject(0) {|sum, step| step[:duration] + sum}
              key.mean_duration = total_duration / steps.length
            end
          end
        end
  
        def worst_status(statuses)
          [:passed, :undefined, :pending, :skipped, :failed].find do |status|
            statuses.include?(status)
          end
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
