# frozen_string_literal: true

class Organization < ApplicationRecord
  belongs_to :organization, foreign_key: 'parent_id', optional: true
  has_many :organizations, foreign_key: 'parent_id'
  has_many :contents

  def self.find_by_name_parts(name_parts)
    prepared_name_parts = name_parts.map { |n| "%#{n}%" }
    sql_query = <<-SQL
      WITH RECURSIVE search_tree AS (
        SELECT id, name, parent_id, ARRAY [id] AS path, name AS full_name
        FROM #{table_name}
        WHERE parent_id IS NULL
        UNION ALL
        SELECT rst.id, rst.name, rst.parent_id, path || rst.id, full_name || ', ' || rst.name
        FROM search_tree
          JOIN #{table_name} AS rst
            ON rst.parent_id = search_tree.id
        WHERE NOT rst.id = ANY (path)
      ), results AS (
          SELECT DISTINCT *
          FROM search_tree
          WHERE full_name ILIKE ALL (ARRAY [?])
      ), parents AS (
        WITH RECURSIVE parents_tree AS (
          SELECT id, parent_id, name FROM results
            UNION
          SELECT rpt.id, rpt.parent_id, rpt.name
          FROM parents_tree JOIN #{table_name} AS rpt ON rpt.id = parents_tree.parent_id
        ) SELECT id, parent_id, name FROM parents_tree
      )
      SELECT * FROM parents
    SQL
    find_by_sql([sql_query, prepared_name_parts])
  end
end
