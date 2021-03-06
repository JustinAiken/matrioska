module Matrioska
  module DialWithApps
    def dial_with_local_apps(to, options = {}, &block)
      dial = Adhearsion::CallController::Dial::ParallelConfirmationDial.new to, options, call

      runner = Matrioska::AppRunner.new call
      yield runner, dial
      runner.start

      dial.track_originating_call
      dial.prep_calls
      dial.place_calls
      dial.await_completion
      dial.cleanup_calls
      dial.status
    end

    def dial_with_remote_apps(to, options = {}, &block)
      dial = Adhearsion::CallController::Dial::ParallelConfirmationDial.new to, options, call

      dial.track_originating_call

      dial.prep_calls do |new_call|
        new_call.on_joined call do
          runner = Matrioska::AppRunner.new new_call
          yield runner, dial
          runner.start
        end
      end

      dial.place_calls
      dial.await_completion
      dial.cleanup_calls
      dial.status
    end
  end
end
