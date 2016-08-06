
class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(name:,breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT);
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id != nil
      self.update
    else
      sql= <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name,self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name:,breed:)
    Dog.new(name:name,breed:breed).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    new_from_db(DB[:conn].execute(sql,id).first)
  end

  def self.new_from_db(row)
    Dog.new(name:row[1],breed:row[2],id:row[0])
  end

  def self.find_or_create_by(name:,breed:)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      dog_data = dog.first
      dog = Dog.new(name:dog_data[1],breed:dog_data[2],id:dog_data[0])
    else
      dog = self.create(name:name,breed:breed)
    end
    dog
  end

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?",name).first
    new_from_db(dog)
  end

end