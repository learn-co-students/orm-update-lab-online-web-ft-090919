require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
    self
  end

  def self.create_table
    sql = <<~SQL
    CREATE TABLE IF NOT EXISTS students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students;"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<~SQL
    INSERT INTO students(name, grade)
    VALUES (?, ?)
    SQL
    binding.pry
    if DB[:conn].execute(sql, self.name, self.grade).empty?
      self.update
    end
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def update
    sql = <<~SQL
    UPDATE students
    SET name = ?,
    grade = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    new_student = self.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    new_student = self.new(row[0], row[1], row[2])
    new_student
  end

  def self.find_by_name(name)
    sql = <<~SQL
    SELECT *
    FROM students
    WHERE name = ?
    LIMIT 1
    SQL

    record = DB[:conn].execute(sql, name)[0]
    self.new_from_db(record)
  end

end
