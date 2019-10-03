#!/usr/bin/env ruby

require_relative "../../ruby_task_helper/files/task_helper.rb"
require 'yaml'

class Run < TaskHelper
  def task(action:,
           environment:,
           name: nil,
           options: nil,
           config: '/etc/puppetlabs/r10k/environments.yaml',
           **kwargs)

    @config = config
    @environment = environment
    @contents = YAML.load_file(@config)

    raise TaskHelper::Error.new("#{@environment} environment does not exist",
                                "puppetctl/validation-error") if @contents[@environment].nil?

    case action
    when 'list'
      list(name)
    when 'add'
      raise TaskHelper::Error.new("`name` parameter is required to add a module",
                                  "puppetctl/input-error") if name.nil?
      raise TaskHelper::Error.new("`options` parameter is required to add a module",
                                  "puppetctl/input-error") if options.nil?
      add(name, options)
    when 'modify'
      raise TaskHelper::Error.new("`name` parameter is required to modify a module",
                                  "puppetctl/input-error") if name.nil?
      raise TaskHelper::Error.new("`options` parameter is required to modify a module",
                                  "puppetctl/input-error") if options.nil?
      modify(name, options)
    when 'remove'
      raise TaskHelper::Error.new("`name` parameter is required to remove a module",
                                  "puppetctl/input-error") if name.nil?
      remove(name)
    else
      'Not implemented'
    end
  end

  def list(name)
    if name.nil?
      {
        environments: {
          @environment => {
            modules: @contents[@environment]['modules'],
          },
        },
      }
    else
      raise TaskHelper::Error.new("module #{name} does not exist in #{@environment} environment",
                                  "puppetctl/validation-error") if @contents.dig(@environment, 'modules', name).nil?

      { environments: { @environment => { 'modules' => { name => @contents.dig(@environment, 'modules', name) } } }
      }
    end
  end

  def add(name, options)
    raise TaskHelper::Error.new("Cannot add #{name}; module already exists in environment #{env}",
                                "puppetctl/validation-error",
                                @contents[name]) unless @contents.dig(@environment, 'modules', name).nil?

    @contents[@environment]['modules'] ||= {}
    @contents[@environment]['modules'].merge!({name => options})
    write_contents

    { result:      'success',
      message:     "#{name} module added to #{@environment} environment",
    }.merge(list(name))
  end

  def modify(name, options)
    raise TaskHelper::Error.new("Cannot modify #{name}; module does not exist in environment #{@environment}",
                                "puppetctl/validation-error",
                                @contents[name]) if @contents.dig(@environment, 'modules', name).nil?

    case
    when options.is_a?(String) || @contents[@environment]['modules'][name].is_a?(String)
      @contents[@environment]['modules'][name] = options
    when @contents[@environment]['modules'][name].is_a?(Hash)
      merged_options = @contents[@environment]['modules'][name].merge(options).reject { |k,v| v.nil? }
      @contents[@environment]['modules'][name] = merged_options
    end

    write_contents

    { result:      'success',
      message:     "#{name} module modified in #{@environment} environment",
    }.merge(list(name))
  end

  def remove(name)
    raise TaskHelper::Error.new("Cannot remove #{name}; module does not exist in #{@environment} environment",
                                "puppetctl/validation-error") if @contents.dig(@environment, 'modules', name).nil?

    @contents[@environment]['modules'].delete(name)
    write_contents

    { result:  'success',
      message: "#{name} module removed from #{@environment} environment"
    }
  end

  def write_contents
    File.open(@config, 'w') do |file|
      file.write(@contents.to_yaml)
    end
  end
end

if __FILE__ == $0
  Run.run
end
