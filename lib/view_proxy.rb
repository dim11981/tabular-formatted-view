# encoding: utf-8

# Viewing module
# threading and synchronization
module Viewing

  # StopError class
  class StopError < Exception
  end

  # ViewProxy class
  # threading proxy
  class ViewProxy

    # initialization
    #
    # @param obj [Object] Target object
    def initialize(obj)
      @obj = obj
      @tg = ThreadGroup.new
      @upd_mon = Monitor.new
      @update = @upd_mon.new_cond
    end

    # thread-safe store call
    #
    # @param key [String] Value in first cell of data row
    # @param values [Array] Values in cells of row
    # @param options [Hash] Options: color styles
    def store(key,values,options)
      @upd_mon.synchronize {
        @obj.store(key,values,options) if @obj.respond_to?('store')
        @update.signal
      }
    end

    # update loop
    #
    # @param name [String] name of viewing thread
    def update(name=nil)
      @thread = Thread.new {
        Thread.current[:name] = (name || "thread #{Thread.current.object_id}")
        loop {
          begin
            @upd_mon.synchronize {
              @update.wait(1)
              Thread.handle_interrupt(RuntimeError => :on_blocking) {
                @obj.update if @obj.respond_to?('update')
                Thread.handle_interrupt(StopError => :immediate) {} if Thread.pending_interrupt?
              }
            }
            Thread.pass
          rescue StopError
            puts "#{Thread.current[:name]}\n  #{Thread.current.inspect}"
            Thread.current.exit
          rescue
            sleep(1)
          end
        }
      }
    end

    # close call
    def close
      @obj.close if @obj.respond_to?('close')
      @thread.raise(StopError, 'stop')
      @thread.join
    end
  end
end
