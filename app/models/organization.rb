# frozen_string_literal: true

class Organization < ApplicationRecord
  include ImageUploader::Attachment(:logo)

  belongs_to :organization, inverse_of: :organization, foreign_key: 'parent_id', optional: true
  has_many :organizations, inverse_of: :organization, foreign_key: 'parent_id'
  has_many :contents, inverse_of: :contents

  validate :unique_per_parent

  def unique_per_parent
    orgs = Organization.where(parent_id: parent_id, short_name: short_name)
    errors.add(:short_name, "must be unique for parent_id #{parent_id}") unless orgs.empty? || (orgs.size == 1 && orgs[0] == self)
  end

  has_and_belongs_to_many :users

  def ancestors
    Organization.find_ancestors(id: id)
  end

  def self.find_by_name_parts(name_parts)
    prepared_name_parts = name_parts.map { |n| "%#{n}%" }
    sql_query = <<-SQL
      WITH RECURSIVE search_tree AS (
        SELECT id, name, short_name, parent_id, ARRAY [id] AS path, name AS full_name, short_name AS full_short_name
        FROM #{table_name}
        WHERE parent_id IS NULL
        UNION ALL
        SELECT rst.id, rst.name, rst.short_name, rst.parent_id, path || rst.id, full_name || rst.name, full_short_name || rst.short_name
        FROM search_tree
          JOIN #{table_name} AS rst
            ON rst.parent_id = search_tree.id
        WHERE NOT rst.id = ANY (path)
      ), results AS (
          SELECT DISTINCT *
          FROM search_tree
          WHERE full_name || full_short_name ILIKE ALL (ARRAY [?])
      ), parents AS (
        WITH RECURSIVE parents_tree AS (
          SELECT id, parent_id, name, short_name FROM results
            UNION
          SELECT rpt.id, rpt.parent_id, rpt.name, rpt.short_name
          FROM parents_tree JOIN #{table_name} AS rpt ON rpt.id = parents_tree.parent_id
        ) SELECT * FROM parents_tree
      )
      SELECT * FROM parents
    SQL
    find_by_sql([sql_query, prepared_name_parts])
  end

  def self.find_ancestors(id:)
    sql_query = <<-SQL
    WITH RECURSIVE tree AS (
      SELECT id, name, short_name, parent_id, ARRAY[id] AS path, name AS full_name
      FROM #{table_name}
      WHERE id = ?
      UNION
      SELECT t.id, t.name, t.short_name, t.parent_id, path || t.id, t.name || '|' || tree.full_name
      FROM tree JOIN #{table_name} AS t
        ON t.id = tree.parent_id
      WHERE NOT t.id = ANY(path)
    ) SELECT id, name, short_name, parent_id FROM tree ORDER BY array_length(path, 1) DESC
    SQL
    find_by_sql([sql_query, id])
  end
end
