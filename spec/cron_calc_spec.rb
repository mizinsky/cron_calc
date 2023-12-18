# frozen_string_literal: true

RSpec.describe CronCalc do
  it 'has a version number' do
    expect(CronCalc::VERSION).not_to be nil
  end

  describe '#occurrences' do
    let(:subject) { described_class.new(cron_string, period).occurrences }

    context 'when "," is used' do
      let(:cron_string) { '30 22,23 * * *' }
      let(:period) { Time.new(2023, 11, 23)..Time.new(2023, 11, 27) }

      it do
        expect(subject).to eq([
                                Time.new(2023, 11, 23, 22, 30),
                                Time.new(2023, 11, 23, 23, 30),
                                Time.new(2023, 11, 24, 22, 30),
                                Time.new(2023, 11, 24, 23, 30),
                                Time.new(2023, 11, 25, 22, 30),
                                Time.new(2023, 11, 25, 23, 30),
                                Time.new(2023, 11, 26, 22, 30),
                                Time.new(2023, 11, 26, 23, 30)
                              ])
      end
    end

    context 'when day is used' do
      let(:cron_string) { '5 5 12 * *' }
      let(:period) { Time.new(2023, 11, 10)..Time.new(2024, 2, 20) }

      it do
        expect(subject).to eq([
                                Time.new(2023, 11, 12, 5, 5),
                                Time.new(2023, 12, 12, 5, 5),
                                Time.new(2024, 1, 12, 5, 5),
                                Time.new(2024, 2, 12, 5, 5)
                              ])
      end
    end

    context 'when month is used' do
      let(:cron_string) { '5 5 12 1 *' }
      let(:period) { Time.new(2023, 11, 10)..Time.new(2024, 2, 20) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 12, 5, 5)
                              ])
      end
    end

    context 'when range "-" is used' do
      let(:cron_string) { '5 5 15-17 * *' }
      let(:period) { Time.new(2023, 1, 10)..Time.new(2023, 2, 20) }

      it do
        expect(subject).to eq([
                                Time.new(2023, 1, 15, 5, 5),
                                Time.new(2023, 1, 16, 5, 5),
                                Time.new(2023, 1, 17, 5, 5),
                                Time.new(2023, 2, 15, 5, 5),
                                Time.new(2023, 2, 16, 5, 5),
                                Time.new(2023, 2, 17, 5, 5)
                              ])
      end
    end

    context 'when step "/" is used' do
      let(:cron_string) { '5 5 28 */3 *' }
      let(:period) { Time.new(2023, 1, 1)..Time.new(2024, 1, 31) }

      it do
        expect(subject).to eq([
                                Time.new(2023, 1, 28, 5, 5),
                                Time.new(2023, 4, 28, 5, 5),
                                Time.new(2023, 7, 28, 5, 5),
                                Time.new(2023, 10, 28, 5, 5),
                                Time.new(2024, 1, 28, 5, 5)
                              ])
      end
    end

    context 'when there is an occurrence with 0 minutes' do
      let(:cron_string) { '* 11-12 28 * *' }
      let(:period) { Time.new(2023, 1, 28, 11, 58)..Time.new(2023, 1, 28, 12, 2) }

      it do
        expect(subject).to eq([
                                Time.new(2023, 1, 28, 11, 58),
                                Time.new(2023, 1, 28, 11, 59),
                                Time.new(2023, 1, 28, 12),
                                Time.new(2023, 1, 28, 12, 1),
                                Time.new(2023, 1, 28, 12, 2)
                              ])
      end
    end

    context 'when invalid cron string is used' do
      let(:cron_string) { '* 40 * * *' }
      let(:period) { Time.new(2023, 1, 1)..Time.new(2023, 1, 2) }

      it do
        expect { subject }.to raise_error(RuntimeError, 'Cron expression is not supported or invalid test')
      end
    end

    context 'when there is short month' do
      let(:cron_string) { '5 5 31 1,2,3,4 *' }
      let(:period) { Time.new(2023, 1, 1, 0, 0)..Time.new(2023, 6, 1, 0, 0) }

      it do
        expect(subject).to eq([
                                Time.new(2023, 1, 31, 5, 5),
                                Time.new(2023, 3, 31, 5, 5)
                              ])
      end
    end
  end
end
