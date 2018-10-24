class Rent < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :book, optional: true

  validates :start_date, :end_date, presence: true

  validate :in_range?, :check_creation

  scope :from_today, -> { where('DATE(?) BETWEEN start_date AND end_date', Time.zone.today) }

  def self.overlapping_ranges(book_id, start_date, end_date)
    where(book_id: book_id).where(
      "(:start_date >= start_date AND :start_date <= end_date) OR
      (:end_date >= start_date AND :end_date <= end_date) OR
      (:start_date <= start_date AND :end_date >= end_date)",
      start_date: start_date,
      end_date: end_date
    )
  end

  protected

  def overlating_conflicts?
    book_id.nil? || Rent.overlapping_ranges(book_id, start_date, end_date).count.zero?
  end

  private

  def check_creation
    errors.add(:model_rent, 'dates creation error') unless overlating_conflicts?
  end

  def in_range?
    errors.add(:model_rent, 'dates range error') unless start_date < end_date
  end
end
