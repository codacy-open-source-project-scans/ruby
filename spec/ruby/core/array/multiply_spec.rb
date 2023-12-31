require_relative '../../spec_helper'
require_relative 'fixtures/classes'
require_relative 'shared/join'

describe "Array#*" do
  it "tries to convert the passed argument to a String using #to_str" do
    obj = mock('separator')
    obj.should_receive(:to_str).and_return('::')
    ([1, 2, 3, 4] * obj).should == '1::2::3::4'
  end

  it "tires to convert the passed argument to an Integer using #to_int" do
    obj = mock('count')
    obj.should_receive(:to_int).and_return(2)
    ([1, 2, 3, 4] * obj).should == [1, 2, 3, 4, 1, 2, 3, 4]
  end

  it "raises a TypeError if the argument can neither be converted to a string nor an integer" do
    obj = mock('not a string or integer')
    ->{ [1,2] * obj }.should raise_error(TypeError)
  end

  it "converts the passed argument to a String rather than an Integer" do
    obj = mock('2')
    def obj.to_int() 2 end
    def obj.to_str() "2" end
    ([:a, :b, :c] * obj).should == "a2b2c"
  end

  it "raises a TypeError is the passed argument is nil" do
    ->{ [1,2] * nil }.should raise_error(TypeError)
  end

  it "raises an ArgumentError when passed 2 or more arguments" do
    ->{ [1,2].send(:*, 1, 2) }.should raise_error(ArgumentError)
  end

  it "raises an ArgumentError when passed no arguments" do
    ->{ [1,2].send(:*) }.should raise_error(ArgumentError)
  end
end

describe "Array#* with an integer" do
  it "concatenates n copies of the array when passed an integer" do
    ([ 1, 2, 3 ] * 0).should == []
    ([ 1, 2, 3 ] * 1).should == [1, 2, 3]
    ([ 1, 2, 3 ] * 3).should == [1, 2, 3, 1, 2, 3, 1, 2, 3]
    ([] * 10).should == []
  end

  it "does not return self even if the passed integer is 1" do
    ary = [1, 2, 3]
    (ary * 1).should_not equal(ary)
  end

  it "properly handles recursive arrays" do
    empty = ArraySpecs.empty_recursive_array
    (empty * 0).should == []
    (empty * 1).should == empty
    (empty * 3).should == [empty, empty, empty]

    array = ArraySpecs.recursive_array
    (array * 0).should == []
    (array * 1).should == array
  end

  it "raises an ArgumentError when passed a negative integer" do
    -> { [ 1, 2, 3 ] * -1 }.should raise_error(ArgumentError)
    -> { [] * -1 }.should raise_error(ArgumentError)
  end

  describe "with a subclass of Array" do
    before :each do
      ScratchPad.clear

      @array = ArraySpecs::MyArray[1, 2, 3, 4, 5]
    end

    it "returns an Array instance" do
      (@array * 0).should be_an_instance_of(Array)
      (@array * 1).should be_an_instance_of(Array)
      (@array * 2).should be_an_instance_of(Array)
    end

    it "does not call #initialize on the subclass instance" do
      (@array * 2).should == [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]
      ScratchPad.recorded.should be_nil
    end
  end
end

describe "Array#* with a string" do
  it_behaves_like :array_join_with_string_separator, :*
end
