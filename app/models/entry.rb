class Entry < ActiveRecord::Base
  has_paper_trail

  ALLOWED_PARAMS = [:namenskuerzel, :kennzahl,
                    :spaltenzahl, :japanische_umschrift,
                    :japanische_umschrift_din,
                    :kanji, :pali, :sanskrit,
                    :chinesisch, :tibetisch,
                    :koreanisch, :weitere_sprachen,
                    :alternative_japanische_lesungen,
                    :schreibvarianten, :deutsche_uebersetzung,
                    :lemma_art, :jahreszahlen,
                    :uebersetzung, :quellen, :literatur,
                    :eigene_ergaenzungen, :quellen_ergaenzungen,
                    :literatur_ergaenzungen, :page_reference,
                    :romaji_order, :lemma_in_katakana,
                    :lemma_in_lateinbuchstaben, :user_id,
                    :freigeschaltet, :abweichende_kennzahl,
                    :japanischer_quelltext,
                    :japanischer_quelltext_bearbeitungsstand,
                    :seite_textblock2005,
                    :bearbeitungsstand]
  BEARBEITUNGS_STAND = [
    'formatiert',
    'unformatiert',
    'unbearbeitet',
    'Code veraltet'
  ]


  belongs_to :user
  has_many :comments
  has_many :entry_docs
  has_many :entry_htmls

  validates :kennzahl, presence: true
  validate :group_lemma_schreibungen_und_aussprachen
  validate :group_uebersetzungen_quellenangaben_literatur_und_ergaenzungen

  before_save :cleanup

  scope :published, -> { where(freigeschaltet: true) }

  def self.search(column = 'all', query)
    column.eql?('all') ? all_columns(query) : single_column(column, query)
  end

  def self.all_columns(query)
    if query
      Entry.where("japanische_umschrift LIKE ? OR
        kanji LIKE ? OR
        namenskuerzel = ? OR
        kennzahl = ? OR
        romaji_order LIKE ? OR
        jahreszahlen LIKE ? OR
        uebersetzung LIKE ?",
        "%#{query}%","%#{query}%", "%#{query}%", "#{query}", "#{query}", "%#{query}%", "%#{query}%")
    end
  end
  def self.single_column(column, query)
    if Entry::BEARBEITUNGS_STAND.include?(column)
      Entry.where(bearbeitungsstand: column).where("japanische_umschrift LIKE ?", "%#{query}%")
    else
      Entry.where("#{column} LIKE ?", "%#{query}%")
    end
  end

  def cleanup
    substituter = Substituter.new
    if self.japanische_umschrift
      self.romaji_order = substituter.substitute(self.japanische_umschrift).downcase
    end
  end

  def group_lemma_schreibungen_und_aussprachen
    if japanische_umschrift.blank? &&
        kanji.blank? &&
        chinesisch.blank? &&
        tibetisch.blank? &&
        koreanisch.blank? &&
        pali.blank? &&
        sanskrit.blank? &&
        weitere_sprachen.blank? &&
        alternative_japanische_lesungen.blank? &&
        schreibvarianten.blank?
      errors[:base] = 'Mindestens ein Feld der Gruppe '\
        "'Lemma-Schreibungen und -Aussprachen' muss ausgefüllt sein!"
    end
  end

  def group_uebersetzungen_quellenangaben_literatur_und_ergaenzungen
    if deutsche_uebersetzung.blank? &&
        uebersetzung.blank? &&
        quellen.blank? &&
        literatur.blank? &&
        eigene_ergaenzungen.blank? &&
        quellen_ergaenzungen.blank? &&
        literatur_ergaenzungen.blank?
      errors[:base] = 'Mindestens ein Feld der Gruppe '\
        "'Uebersetzungen , Quellenangaben, Literatur und Ergaenzungen' "\
        "muss ausgefüllt sein!"
    end
  end

  def self.label_unprocessed
    Entry.all.each do |entry|
      if entry.unprocessed? && entry.bearbeitungsstand.blank?
        entry.update(bearbeitungsstand: 'unbearbeitet')
      end
    end
  end

  def unprocessed?
    leer_or_nil? || basic_identifier?
  end

  def leer_or_nil?
    self.uebersetzung.nil? || self.uebersetzung.empty? || self.uebersetzung.downcase == 'leer' || /<p>leer<\/p>/ === self.uebersetzung.downcase
  end

  def basic_identifier?
    /Lemma/ === self.uebersetzung[0..38] && /SBDJ/ === self.uebersetzung[0..38]
  end
end
