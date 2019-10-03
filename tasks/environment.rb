#!/usr/bin/env ruby

require_relative "../../ruby_task_helper/files/task_helper.rb"
require 'yaml'

class Run < TaskHelper
  def task(action:,
           name: nil,
           options: nil,
           config: '/etc/puppetlabs/r10k/environments.yaml',
           **kwargs)

    @config = config
    @contents = YAML.load_file(@config) || {}

    case action
    when 'list'
      list(name)
    when 'add'
      raise TaskHelper::Error.new("`name` parameter is required to add an environment",
                                  "puppetctl/input-error") if name.nil?
      raise TaskHelper::Error.new("`options` parameter is required to add an environment",
                                  "puppetctl/input-error") if options.nil?
      add(name, options)
    when 'modify'
      raise TaskHelper::Error.new("`name` parameter is required to modify an environment",
                                  "puppetctl/input-error") if name.nil?
      raise TaskHelper::Error.new("`options` parameter is required to modify an environment",
                                  "puppetctl/input-error") if options.nil?
      modify(name, options)
    when 'remove'
      raise TaskHelper::Error.new("`name` parameter is required to remove an environment",
                                  "puppetctl/input-error") if name.nil?
      remove(name)
    else
      'Not implemented'
    end
  end

  def list(name)
    if name.nil?
      { environments: @contents }
    else
      { environments: { name => @contents[name] } }
    end
  end

  def add(name, options)
    raise TaskHelper::Error.new("Cannot add #{name}; environment already exists",
                                "puppetctl/validation-error",
                                @contents[name]) unless @contents[name].nil?

    @contents[name] = options
    write_contents

    { result:      'success',
      message:     "#{name} environment added!",
      environment: @contents[name],
    }
  end

  def modify(name, options)
    @contents[name] = @contents[name].merge(options).reject { |k,v| v.nil? }
    write_contents

    { result:      'success',
      message:     "#{name} environment modified!",
      environment: @contents[name],
    }
  end

  def remove(name)
    raise TaskHelper::Error.new("Cannot remove #{name}; environment does not exist",
                                "puppetctl/validation-error",
                               @contents[name]) if @contents[name].nil?

    @contents.delete(name)
    write_contents

    { result:  'success',
      message: "#{name} environment removed!"
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
