require 'stock_quote/symbol'
require 'stock_quote/utility'
require 'spec_helper'

describe StockQuote::Symbol do
  describe 'lookup' do
    context 'success' do
      describe 'apple company', vcr: { cassette_name: 'apple_lookup' } do
        @fields = StockQuote::Symbol::FIELDS

        @fields.each do |field|
          it ".#{to_underscore(field)}" do
            symbol = StockQuote::Symbol.lookup('apple').first
            expect(symbol).to respond_to(to_underscore(field).to_sym)
          end

          it ".#{field}" do
            symbol = StockQuote::Symbol.lookup('apple').first
            expect(symbol).to respond_to(field.to_sym)
          end
        end

        it 'returns sucessful result for query with company name' do
          symbols = StockQuote::Symbol.lookup('apple')
          expect(symbols.count).to eq(10)
          expect(symbols.map(&:symbol)).to include('AAPL')
          expect(symbols.map(&:exch)).to include('NYQ')
        end

        it 'returns only symbols for specified exchanges' do
          symbols = StockQuote::Symbol.lookup('apple', ['NYQ'])
          expect(symbols.count).to eq(1)
          symbol = symbols.first
          expect(symbol.name).to eq('Apple Hospitality REIT, Inc.')
          expect(symbol.symbol).to eq('APLE')
          expect(symbol.exch).to eq('NYQ')
          expect(symbol.exch_disp).to eq('NYSE')
          expect(symbol.type).to eq('S')
          expect(symbol.type_disp).to eq('Equity')
        end

        it 'does not return any symbols for fake exchange' do
          symbols = StockQuote::Symbol.lookup('apple', ['AAAA'])
          expect(symbols.count).to eq(0)
        end
      end
    end # context 'success'

    context 'failure' do
      describe 'fake company', vcr: { cassette_name: 'fake_company_lookup' } do
        it 'returns empty set for query with invalid company name' do
          symbols = StockQuote::Symbol.lookup('XYZ123')
          expect(symbols).to be_empty
        end
      end
    end
  end # describe 'lookup'
end # describe StockQuote::Symbol
