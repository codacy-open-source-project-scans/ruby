require_relative '../../spec_helper'

describe "Process.detach" do
  platform_is_not :windows do
    it "returns a thread" do
      pid = Process.fork { Process.exit! }
      thr = Process.detach(pid)
      thr.should be_kind_of(Thread)
      thr.join
    end

    it "produces the exit Process::Status as the thread value" do
      pid = Process.fork { Process.exit! }
      thr = Process.detach(pid)
      thr.join

      status = thr.value
      status.should be_kind_of(Process::Status)
      status.pid.should == pid
    end

    platform_is_not :openbsd do
      it "reaps the child process's status automatically" do
        pid = Process.fork { Process.exit! }
        Process.detach(pid).join
        -> { Process.waitpid(pid) }.should raise_error(Errno::ECHILD)
      end
    end

    it "sets the :pid thread-local to the PID" do
      pid = Process.fork { Process.exit! }
      thr = Process.detach(pid)
      thr.join

      thr[:pid].should == pid
    end

    it "provides a #pid method on the returned thread which returns the PID" do
      pid = Process.fork { Process.exit! }
      thr = Process.detach(pid)
      thr.join

      thr.pid.should == pid
    end

    it "tolerates not existing child process pid" do
      # Use a value that is close to the INT_MAX (pid usually is signed int).
      # It should (at least) be greater than allowed pid limit value that depends on OS.
      pid_not_existing = 2.pow(30)

      # Check that there is no a child process with this hardcoded pid.
      # Command `kill 0 pid`:
      # - returns "1" if a process exists and
      # - raises Errno::ESRCH otherwise
      -> {  Process.kill(0, pid_not_existing) }.should raise_error(Errno::ESRCH)

      thr = Process.detach(pid_not_existing)
      thr.join

      thr.should be_kind_of(Thread)
    end

    it "calls #to_int to implicitly convert non-Integer pid to Integer" do
      pid = MockObject.new('mock-enumerable')
      pid.should_receive(:to_int).and_return(100500)

      Process.detach(pid).join
    end

    it "raises TypeError when pid argument does not have #to_int method" do
      -> { Process.detach(Object.new) }.should raise_error(TypeError, "no implicit conversion of Object into Integer")
    end

    it "raises TypeError when #to_int returns non-Integer value" do
      pid = MockObject.new('mock-enumerable')
      pid.should_receive(:to_int).and_return(:symbol)

      -> { Process.detach(pid) }.should raise_error(TypeError, "can't convert MockObject to Integer (MockObject#to_int gives Symbol)")
    end
  end
end
