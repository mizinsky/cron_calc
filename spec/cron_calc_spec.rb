# frozen_string_literal: true

RSpec.describe CronCalc do
  it 'has a version number' do
    expect(CronCalc::VERSION).not_to be nil
  end

  describe '#in & #occurrences' do
    let(:subject) { described_class.new(cron_string).in(period) }

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
        expect { subject }.to raise_error(RuntimeError, 'Cron expression is not supported or invalid')
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

    context 'when DOW (day of the week) is used' do
      let(:cron_string) { '5 5 * * 0' }
      let(:period) { Time.new(2024, 1, 1, 0, 0)..Time.new(2024, 2, 1, 0, 0) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 7, 5, 5),
                                Time.new(2024, 1, 14, 5, 5),
                                Time.new(2024, 1, 21, 5, 5),
                                Time.new(2024, 1, 28, 5, 5)
                              ])
      end
    end

    context 'when wdays excludes days of month' do
      let(:cron_string) { '5 5 14-22 * 0,6' }
      let(:period) { Time.new(2024, 1, 1, 0, 0)..Time.new(2024, 2, 1, 0, 0) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 14, 5, 5),
                                Time.new(2024, 1, 20, 5, 5),
                                Time.new(2024, 1, 21, 5, 5)
                              ])
      end
    end

    context 'when named months are used' do
      let(:cron_string) { '5 5 5 JAN,FEB *' }
      let(:period) { Time.new(2024, 1, 1, 0, 0)..Time.new(2024, 3, 31, 0, 0) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 5, 5, 5),
                                Time.new(2024, 2, 5, 5, 5)
                              ])
      end
    end

    context 'when named wdays are used' do
      let(:cron_string) { '5 5 1-8 FEB TUE-THU' }
      let(:period) { Time.new(2024, 1, 1, 0, 0)..Time.new(2024, 3, 31, 0, 0) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 2, 1, 5, 5),
                                Time.new(2024, 2, 6, 5, 5),
                                Time.new(2024, 2, 7, 5, 5),
                                Time.new(2024, 2, 8, 5, 5)
                              ])
      end
    end

    context 'when predefined definition @daily is used' do
      let(:cron_string) { '@daily' }
      let(:period) { Time.new(2024, 1, 1, 0, 0)..Time.new(2024, 1, 4, 15, 0) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 1, 0, 0),
                                Time.new(2024, 1, 2, 0, 0),
                                Time.new(2024, 1, 3, 0, 0),
                                Time.new(2024, 1, 4, 0, 0)
                              ])
      end
    end

    context 'when predefined definition @weekly is used' do
      let(:cron_string) { '@weekly' }
      let(:period) { Time.new(2024, 1, 1, 0, 0)..Time.new(2024, 2, 1, 0, 0) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 7, 0, 0),
                                Time.new(2024, 1, 14, 0, 0),
                                Time.new(2024, 1, 21, 0, 0),
                                Time.new(2024, 1, 28, 0, 0)
                              ])
      end
    end

    context 'when predefined definition @monthly is used' do
      let(:cron_string) { '@monthly' }
      let(:period) { Time.new(2024, 1, 1, 0, 0)..Time.new(2024, 3, 1, 0, 0) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 1, 0, 0),
                                Time.new(2024, 2, 1, 0, 0),
                                Time.new(2024, 3, 1, 0, 0)
                              ])
      end
    end

    context 'when predefined definition @annually is used' do
      let(:cron_string) { '@annually' }
      let(:period) { Time.new(2024, 1, 1, 0, 0)..Time.new(2026, 2, 1, 0, 0) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 1, 0, 0),
                                Time.new(2025, 1, 1, 0, 0),
                                Time.new(2026, 1, 1, 0, 0)
                              ])
      end
    end

    context 'when predefined definition @hourly is used' do
      let(:cron_string) { '@hourly' }
      let(:period) { Time.new(2024, 1, 1, 0, 0)..Time.new(2024, 1, 1, 5, 50) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 1, 0, 0),
                                Time.new(2024, 1, 1, 1, 0),
                                Time.new(2024, 1, 1, 2, 0),
                                Time.new(2024, 1, 1, 3, 0),
                                Time.new(2024, 1, 1, 4, 0),
                                Time.new(2024, 1, 1, 5, 0)
                              ])
      end
    end

    context 'when ,- are used in single cron part' do
      let(:cron_string) { '5 5 1,4-6 * *' }
      let(:period) { Time.new(2024, 1, 1, 0, 0)..Time.new(2024, 1, 7, 23, 50) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 1, 5, 5),
                                Time.new(2024, 1, 4, 5, 5),
                                Time.new(2024, 1, 5, 5, 5),
                                Time.new(2024, 1, 6, 5, 5)
                              ])
      end
    end

    context 'when -, are used in single cron part' do
      let(:cron_string) { '5 5 7-9,27,30 * *' }
      let(:period) { Time.new(2024, 1, 1, 0, 0)..Time.new(2024, 2, 1, 0, 0) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 7, 5, 5),
                                Time.new(2024, 1, 8, 5, 5),
                                Time.new(2024, 1, 9, 5, 5),
                                Time.new(2024, 1, 27, 5, 5),
                                Time.new(2024, 1, 30, 5, 5)
                              ])
      end
    end

    context 'when * and / are used in single cron part for minutes' do
      let(:cron_string) { '*/15 * * * *' }
      let(:period) { Time.new(2024, 1, 1, 0, 0)..Time.new(2024, 1, 1, 1, 20) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 1, 0, 0),
                                Time.new(2024, 1, 1, 0, 15),
                                Time.new(2024, 1, 1, 0, 30),
                                Time.new(2024, 1, 1, 0, 45),
                                Time.new(2024, 1, 1, 1, 0),
                                Time.new(2024, 1, 1, 1, 15)
                              ])
      end
    end

    context 'when * and / are used in single cron part for days' do
      let(:cron_string) { '5 5 */5 * *' }
      let(:period) { Time.new(2024, 1, 1, 0, 0)..Time.new(2024, 1, 29, 0, 0) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 1, 5, 5),
                                Time.new(2024, 1, 6, 5, 5),
                                Time.new(2024, 1, 11, 5, 5),
                                Time.new(2024, 1, 16, 5, 5),
                                Time.new(2024, 1, 21, 5, 5),
                                Time.new(2024, 1, 26, 5, 5)
                              ])
      end
    end

    context 'when complex cron string' do
      let(:cron_string) { '5 5 */15 */3 MON-TUE,SAT' }
      let(:period) { Time.new(2024, 1, 1, 0, 0)..Time.new(2025, 1, 1, 0, 0) }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 1, 5, 5),
                                Time.new(2024, 1, 16, 5, 5),
                                Time.new(2024, 4, 1, 5, 5),
                                Time.new(2024, 4, 16, 5, 5),
                                Time.new(2024, 7, 1, 5, 5),
                                Time.new(2024, 7, 16, 5, 5),
                                Time.new(2024, 10, 1, 5, 5)
                              ])
      end
    end
  end

  describe '#next' do
    let(:subject) { described_class.new(cron_string).next(n, after: after) }
    let(:n) { 3 }
    let(:after) { Time.new(2024, 1, 1, 0, 0) }

    context 'when "," is used' do
      let(:cron_string) { '30 22,23 * * *' }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 1, 22, 30),
                                Time.new(2024, 1, 1, 23, 30),
                                Time.new(2024, 1, 2, 22, 30)
                              ])
      end
    end

    context 'when count parameter is missing' do
      let(:subject) { described_class.new(cron_string).next(after: after) }
      let(:cron_string) { '30 22,23 * * *' }

      it do
        expect(subject).to eq([
                                Time.new(2024, 1, 1, 22, 30)
                              ])
      end
    end
  end

  describe '#last' do
    let(:subject) { described_class.new(cron_string).last(n, before: before) }
    let(:n) { 3 }
    let(:before) { Time.new(2024, 1, 1, 0, 0) }

    context 'when "," is used' do
      let(:cron_string) { '30 22,23 * * *' }

      it do
        expect(subject).to eq([
                                Time.new(2023, 12, 31, 23, 30),
                                Time.new(2023, 12, 31, 22, 30),
                                Time.new(2023, 12, 30, 23, 30)
                              ])
      end
    end

    context 'when count parameter is missing' do
      let(:subject) { described_class.new(cron_string).last(before: before) }
      let(:cron_string) { '30 22,23 * * *' }

      it do
        expect(subject).to eq([
                                Time.new(2023, 12, 31, 23, 30)
                              ])
      end
    end
  end
end
