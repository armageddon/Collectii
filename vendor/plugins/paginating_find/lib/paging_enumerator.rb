# An enumerable that iterates through "pages" of objects.
# A page is loaded by the block callback provided to the initializer.
#
#   pe = PagingEnumerable.new(25, 593) do |current_page|
#     # return all results for the current_page
#   end
#   pe.each { |result| puts result }
#
# Specify the auto = true if you want the enumerator
# to iterate over all items rather than those on the
# current page. If this option is enabled
# you may to the next page by invoking the next_page! method,
# or you may skip to any page using the move!(page) method.
#
class PagingEnumerator
  include Enumerable

  attr_accessor :results, :page, :first_page, :last_page, :stop_page, :page_size, :page_count, :size, :auto

  def initialize(page_size, size, auto = false, page = 1, first_page=page, &callback)
    self.page = page.to_i
    self.page_size = page_size.to_i
    self.size = size.to_i
    self.auto = auto
    self.first_page = first_page.to_i
    self.last_page = page_count.to_i
    self.stop_page = auto ? last_page : self.page
    @callback = callback
  end
  
  def each
    early_termination = false
    while page <= stop_page && !early_termination
      load_page
      if results.respond_to?(:each)
        results.each { |r| yield r }
      else
        yield results
      end
      self.page = self.page + 1
      if (results.respond_to?(:size) && results.size < page_size)
        early_termination = true
      end
    end
    # force usage of next_page method
    self.page = self.page - 1
  end
  
  def move!(page)
    raise ArgumentError, "manually moving pages is only supported when auto paging is disabled" if auto
    if page < self.first_page
      self.page = first_page
    elsif page > self.last_page
      self.page = last_page
    else
      self.page = page
    end
    self.stop_page = page
  end
  
  def page_exists?(page)
    page >= self.first_page && page <= self.last_page
  end
  
  def first_page!
    move!(first_page)
  end
  
  def last_page!
    move!(last_page)
  end
  
  # Move to the next page if auto paging is disabled.
  def next_page!
    move!(next_page) if next_page?
  end
  
  def next_page?
    next_page ? true : false
  end
  
  def next_page
    if page >= page_count
      nil
    else
      page + 1
    end
  end
  
  # Move to the previous page if auto paging is disabled.
  def previous_page!
    move!(previous_page) if previous_page?
  end
  
  def previous_page?
    previous_page ? true : false
  end
  
  def previous_page
    if page == first_page
      nil
    else
      page - 1
    end
  end
  
  def first_item
    ((self.page-1) * self.page_size) + 1
  end
  
  def last_item
    [self.page * self.page_size, self.size].min
  end

  # How many pages are available?
  def page_count
    @page_count ||= (empty? or page_size == 0) ? 1 : (q, r = size.divmod(page_size); r == 0 ? q : q + 1)
  end
  
  def empty?
    size == 0
  end
  
  # Get the results as an array. If the enumerator is using manual_paging, this array
  # will contain just the current page. Otherwise, this method will iterate all pages
  # and return them as an array.
  def to_a
    array = []
    each { |e| array << e }
    array
  end

  # Load the next page using the callback
  def load_page
    self.results = @callback.call(page)
  end
    
end
