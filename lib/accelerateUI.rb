require 'require_all'
require_all 'lib/parsers'
require_all 'lib/generators'

class AccelerateUI
  # Инициализируем все переменные которые в дальнейшем нужны будут в работе класса.
  # Места расположения директорий, парсеры и генераторы
  def initialize
    #TODO: Here we create base variables for all functionality
    @js_dir = 'app/assets/javascripts'
    @style_dir = 'app/assets/stylesheets'

    #TODO: Refactor for call function which will return variables by param. For example - js, css, html.
    work_file_variable("lib/parsers", "lib/generators")
  end

  # Основная функция которая делает всю обработку
  def accelerate
    #TODO: Here we must call all functionality about js, css and about html
    @id_array = []
    @class_array = []

    define_all_entries
    collect_ids
  end

  #private

  # Получаем все файлы для каждой категории ccs, js, html
  def define_all_entries
    entries_javascript
    #entries_css
    #entries_html
  end

  # Собираем айдишники / классы с каждого типа
  def collect_ids
    @js_files.each do |file|
      @id_array += js_file_ids(file)
      #@class_array += js_file_classes(file)
    end

    count_entries
    sorted_array_by_entries
    added_new_ids

    @js_files.each do |file|
      # Тут вызов генератора нада добавить для замены айдишников
      full_path = "#{@js_dir}/#{file}"
      @js_generator.id_generator(full_path, @id_array)
    end
  end

  # Получаем список js-файлов
  def entries_javascript
    @js_files = Dir.entries(@js_dir).select { |f| !File.directory? f }
  end

  # Получаем список css-файлов
  def entries_css
    @css_files = Dir.entries(@style_dir).select { |f| !File.directory? f }
  end

  # Открываем файл и содержание передаем в парсер.
  # Должны получить на выходе массив.
  def js_file_ids(file)
    f = File.open("#{@js_dir}/#{file}", "r")
    @js_parser.id_parser(IO.read(f))
  end

  # Так как стандартная сортировка нам дает масив от меньше до больше делаем реверс массива чтобы было наоборот
  def sorted_array_by_entries
    @id_array = @id_array.sort_by { |id| id[:count] }.reverse
  end

  # Добавляем к @id_array новый ключ - 'new_name' на каждой итерации при помощи функции next делаю прирост строки
  def added_new_ids
    new_name = 'a'

    @id_array.each do |array_element|
      array_element[:new_name] = "##{new_name}"
      new_name = new_name.next
    end unless @id_array.empty?
  end

  # Пересчитываем количество вхождений каждого id в массиве и пересчитав его перезаполняю массив @id_array
  def count_entries
    temp_array = []

    until @id_array.empty? do
      element = @id_array.first
      temp_array << { name: element, count: @id_array.count(element) }
      @id_array.delete(element)
    end

    @id_array = temp_array
  end

  # Заводим переменные для всех рабочих файлов(пока только парсеры и генераторы)
  # Внутрь передается список элементов и внутри пробегаясь ичем создаются все необходимые
  def work_file_variable(*work_files_path)
    work_files_path.each do |path|
      work_files = []
      Dir.foreach("#{Rails.root}/#{path}"){ |file| work_files << file.split('.rb').first unless File.directory?(file) }
      work_files.each { |parser| instance_variable_set("@#{parser}", parser.humanize.titleize.delete(' ').constantize.new) }
    end
  end
end