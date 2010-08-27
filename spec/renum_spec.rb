require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

enum :Status, [ :NOT_STARTED, :IN_PROGRESS, :COMPLETE ]

enum :Fuzzy, [ :FooBar, :BarFoo ]

describe "basic enum" do

  it "creates a class for the value type" do
    Status.should be_an_instance_of(Class)
  end

  it "makes each value an instance of the value type" do
    Status::NOT_STARTED.should be_an_instance_of(Status)
  end

  it "exposes array of values" do
    Status.values.should == [Status::NOT_STARTED, Status::IN_PROGRESS, Status::COMPLETE]
    Status.all.should == [Status::NOT_STARTED, Status::IN_PROGRESS, Status::COMPLETE]
  end

  it "groks first and last to retreive value" do
    Status.first.should == Status::NOT_STARTED
    Status.last.should == Status::COMPLETE
  end

  it "enumerates over values" do
    Status.map {|s| s.name}.should == %w[NOT_STARTED IN_PROGRESS COMPLETE]
  end

  it "indexes values" do
    Status[2].should == Status::COMPLETE
    Color[0].should == Color::RED
  end

  it "provides index lookup on values" do
    Status::IN_PROGRESS.index.should == 1
    Color::GREEN.index.should == 1
  end

  it "provides name lookup on values" do
    Status.with_name('IN_PROGRESS').should == Status::IN_PROGRESS
    Color.with_name('GREEN').should == Color::GREEN
    Color.with_name('IN_PROGRESS').should be_nil
  end

  it "provides fuzzy name lookup on values" do
    Fuzzy[0].should == Fuzzy::FooBar
    Fuzzy[1].should == Fuzzy::BarFoo
    Fuzzy[:FooBar].should == Fuzzy::FooBar
    Fuzzy[:BarFoo].should == Fuzzy::BarFoo
    Fuzzy['FooBar'].should == Fuzzy::FooBar
    Fuzzy['BarFoo'].should == Fuzzy::BarFoo
    Fuzzy[:foo_bar].should == Fuzzy::FooBar
    Fuzzy[:bar_foo].should == Fuzzy::BarFoo
    Fuzzy['foo_bar'].should == Fuzzy::FooBar
    Fuzzy['bar_foo'].should == Fuzzy::BarFoo
  end

  it "provides a reasonable to_s for values" do
    Status::NOT_STARTED.to_s.should == "Status::NOT_STARTED"
  end

  it "makes values comparable" do
    Color::RED.should < Color::GREEN
  end
end

module MyNamespace
  enum :FooValue, %w( Bar Baz Bat )
end

describe "nested enum" do
  it "is namespaced in the containing module or class" do
    MyNamespace::FooValue::Bar.class.should == MyNamespace::FooValue
  end
end

enum :Color, [ :RED, :GREEN, :BLUE ] do
  def abbr
    name[0..0]
  end
end

describe "enum with a block" do
  it "can define additional instance methods" do
    Color::RED.abbr.should == "R"
  end
end

enum :Size do
  Small("Really really tiny")
  Medium("Sort of in the middle")
  Large("Quite big")
  Unknown()

  attr_reader :description

  def init description = nil
    @description = description || "NO DESCRIPTION GIVEN"
  end
end

enum :HairColor do
  BLONDE()
  BRUNETTE()
  RED()
end

describe "enum with no values array and values declared in the block" do
  it "provides another way to declare values where an init method can take extra params" do
    Size::Small.description.should == "Really really tiny"
  end

  it "works the same as the basic form with respect to ordering" do
    Size.values.should == [Size::Small, Size::Medium, Size::Large, Size::Unknown]
  end

  it "responds as expected to arbitrary method calls, in spite of using method_missing for value definition" do
    lambda { Size.ExtraLarge() }.should raise_error(NoMethodError)
  end

  it "supports there being no extra data and no init() method defined, if you don't need them" do
    HairColor::BLONDE.name.should == "BLONDE"
  end

  it "calls the init method even if no arguments are provided" do
    Size::Unknown.description.should == "NO DESCRIPTION GIVEN"
  end
end

enum :Rating do
  NotRated()

  ThumbsDown do
    def description
      "real real bad"
    end
  end

  ThumbsUp do
    def description
      "so so good"
    end

    def thumbs_up_only_method
      "this method is only defined on ThumbsUp"
    end
  end

  def description
    raise NotImplementedError
  end
end

describe "an enum with instance-specific method definitions" do
  it "allows each instance to have its own behavior" do
    Rating::ThumbsDown.description.should == "real real bad"
    Rating::ThumbsUp.description.should == "so so good"
  end

  it "uses the implementation given at the top level if no alternate definition is given for an instance" do
    lambda { Rating::NotRated.description }.should raise_error(NotImplementedError)
  end

  it "allows definition of a method on just one instance" do
    Rating::ThumbsUp.thumbs_up_only_method.should == "this method is only defined on ThumbsUp"
    lambda { Rating::NotRated.thumbs_up_only_method }.should raise_error(NoMethodError)
  end
end

describe "<=> comparison issue that at one time was causing segfaults on MRI" do
  it "doesn't cause the ruby process to bomb!" do
    Color::RED.should < Color::GREEN
    Color::RED.should_not > Color::GREEN
    Color::RED.should < Color::BLUE
  end
end

describe "prevention of subtle and annoying bugs" do
  it "prevents you modifying the values array" do
    lambda { Color.values << 'some crazy value' }.should raise_error(TypeError, /can't modify frozen/)
  end

  it "prevents you modifying the name hash" do
    lambda { Color.values_by_name['MAGENTA'] = 'some crazy value' }.should raise_error(TypeError, /can't modify frozen/)
  end

  it "prevents you modifying the name of a value" do
    lambda { Color::RED.name << 'dish-Brown' }.should raise_error(TypeError, /can't modify frozen/)
  end
end

enum :Foo1 do
  field :foo
  field :bar, :default => 'my bar'
  field :baz do |obj|
    obj.__id__
  end

  Baz(
    :foo => 'my foo'
  )
end

enum :Foo2 do
  field :foo
  field :bar, :default => 'my bar'
  field :baz do |obj|
    obj.__id__
  end


  Baz(
    :foo => 'my foo'
  )

  def init(opts = {})
    super
  end
end

describe "use field method to specify methods and defaults" do
  it "should define methods with defaults for fields" do
    Foo1::Baz.foo.should == "my foo"
    Foo2::Baz.foo.should == "my foo"
    Foo1::Baz.bar.should == "my bar"
    Foo2::Baz.bar.should == "my bar"
    Foo1::Baz.baz.should == Foo1::Baz.__id__
    Foo2::Baz.baz.should == Foo2::Baz.__id__
  end
end
