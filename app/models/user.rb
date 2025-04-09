class User < ApplicationRecord
    has_many :events, dependent: :destroy
    has_many :subscriptions, dependent: :destroy
    has_many :subscribed_events, through: :subscriptions, source: :event
    has_many :notifications, dependent: :destroy
    has_secure_password

    validates :nome, presence: {message: "è obbligatorio"}
    validates :cognome, presence: {message: "è obbligatorio"}
    validates :telefono, presence: {message: "è obbligatorio"}, format: { with: /\A\d{10}\z/, message: "deve contenere esattamente 10 cifre" }
    validate :data_nascita_check
    validates :tipo, presence: {message: "è obbligatorio"}
    validates :email, presence: {message: "è obbligatoria"}, uniqueness: { case_sensitive: false, message: "è già stata registrata" }, format: {with: /\A[^@\s]+@[^@\s]+\z/, message: "non ha un formato valido"}
    validates :password, presence: {message: "è obbligatoria"}, length: {minimum: 8, message: "deve essere di almeno 8 caratteri"}
    validate :passwords_match

    private

    def data_nascita_check
        if data_nascita.present?
            if data_nascita > Date.today
                errors.add(:base, "Data di nascita non può essere nel futuro")
            end
        else
            errors.add(:base, "Data di nascita è obbligatoria")
        end
    end

    def passwords_match
        if password.present? && password != password_confirmation
            errors.add(:base, "Le password non coincidono")
        end
    end
end
