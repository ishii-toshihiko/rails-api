# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Skill.create(category:"soft",item:"Ruby",term: 20)
Skill.create(category:"soft",item:"Ruby On Rails",term: 9)
Skill.create(category:"soft",item:"HTML",term: 10)
Skill.create(category:"soft",item:"CSS",term: 10)
Skill.create(category:"soft",item:"PostgreSQL",term: 20)
Skill.create(category:"soft",item:"SQL",term: 20)
Skill.create(category:"soft",item:"C",term: 10)
Skill.create(category:"soft",item:"アセンブラ",term: 10)
Skill.create(category:"soft",item:"Docker",term: 1)
Skill.create(category:"soft",item:"React",term: 1)
Skill.create(category:"soft",item:"Typescript",term: 1)
Skill.create(category:"soft",item:"Rspec",term: 1)
Skill.create(category:"heard",item:"デジタル回路",term: 25)
Skill.create(category:"heard",item:"アナログ回路",term: 16)
Skill.create(category:"heard",item:"VHDL",term: 3)
Skill.create(category:"heard",item:"AHDL",term: 9)
Skill.create(category:"heard",item:"FPGA設計",term: 3)
Skill.create(category:"heard",item:"DSPソフト設計",term: 18)
