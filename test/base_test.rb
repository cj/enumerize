require 'test_helper'

describe Enumerize::Base do
  let(:klass) do
    Class.new do
      include Enumerize
    end
  end

  let(:object) { klass.new }

  it 'returns nil when not set' do
    klass.enumerize(:foo, :in => [:a, :b])
    object.foo.must_equal nil
  end

  it 'returns value that was set' do
    klass.enumerize(:foo, :in => [:a, :b])
    object.foo = :a
    object.foo.must_equal 'a'
  end

  it 'returns translation' do
    store_translations(:en, :enumerize => {:foo => {:a => 'a text'}}) do
      klass.enumerize(:foo, :in => [:a, :b])
      object.foo = :a
      object.foo.text.must_equal 'a text'
      object.foo_text.must_equal 'a text'
      object.foo_text.must_equal 'a text'
    end
  end

  it 'returns nil as translation when value is nil' do
    store_translations(:en, :enumerize => {:foo => {:a => 'a text'}}) do
      klass.enumerize(:foo, :in => [:a, :b])
      object.foo_text.must_equal nil
    end
  end

  it 'scopes translation by i18 key' do
    def klass.model_name
      name = "ExampleClass"
      def name.i18n_key
        'example_class'
      end

      name
    end

    store_translations(:en, :enumerize => {:example_class => {:foo => {:a => 'a text scoped'}}}) do
      klass.enumerize(:foo, :in => [:a, :b])
      object.foo = :a
      object.foo.text.must_equal 'a text scoped'
      object.foo_text.must_equal 'a text scoped'
    end
  end

  it 'returns humanized value if there are no translations' do
    store_translations(:en, :enumerize => {}) do
      klass.enumerize(:foo, :in => [:a, :b])
      object.foo = :a
      object.foo_text.must_equal 'A'
    end
  end

  it 'stores value as string' do
    klass.enumerize(:foo, :in => [:a, :b])
    object.foo = :a
    object.instance_variable_get(:@foo).must_be_instance_of String
  end

  it 'handles default value' do
    klass.enumerize(:foo, :in => [:a, :b], :default => :b)
    object.foo.must_equal 'b'
  end

  it 'raises exception on invalid default value' do
    proc {
      klass.enumerize(:foo, :in => [:a, :b], :default => :c)
    }.must_raise ArgumentError
  end

  it 'has enumerized attributes' do
    klass.enumerized_attributes.must_equal({})
    klass.enumerize(:foo, :in => %w[a b])
    klass.enumerized_attributes[:foo].must_be_instance_of Enumerize::Attribute
  end

  it "doesn't override existing method" do
    method = klass.method(:name)
    klass.enumerize(:name, :in => %w[a b], :default => 'a')
    klass.method(:name).must_equal method
  end
end
