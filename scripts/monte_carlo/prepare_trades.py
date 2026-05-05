#!/usr/bin/env python3
"""
Prepare trades.csv for Monte Carlo Risk Assessment.

Converts MetaTrader 5 Strategy Tester report exports to the simple
CSV format expected by MonteCarlo_RiskAssessor.mq5.

Usage:
  python3 prepare_trades.py <input_file> [output_file]

Input formats supported:
  1. Strategy Tester HTML report (right-click > Save as Report)
  2. Strategy Tester CSV export
  3. Simple one-column profit list

Output: trades.csv with header "Profit" and one P&L value per line.
"""

import sys
import re
import csv
from pathlib import Path


def extract_from_html(filepath):
    """Extract trade profits from MT5 Strategy Tester HTML report."""
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Pattern: look for trade table rows with profit values
    # MT5 HTML reports have a table with columns including Profit
    profits = []
    
    # Try to find the deals/trades table
    # MT5 reports use <td> tags with profit values
    # Look for patterns like: <td>...</td><td>...profit...</td>
    
    # Method 1: Find all numeric values in profit-like columns
    # MT5 HTML report structure: Ticket, Time, Type, Order, Lots, Price, S/L, T/P, Profit, Balance
    rows = re.findall(r'<tr[^>]*>(.*?)</tr>', content, re.DOTALL)
    
    for row in rows:
        cells = re.findall(r'<td[^>]*>(.*?)</td>', row, re.DOTALL)
        if len(cells) >= 8:
            # Check if this looks like a trade row (has ticket number in first cell)
            first_cell = re.sub(r'<[^>]+>', '', cells[0]).strip()
            if first_cell.isdigit() and len(first_cell) > 3:
                # Find the profit cell (usually last or second-to-last)
                for cell in reversed(cells):
                    val = re.sub(r'<[^>]+>', '', cell).strip()
                    val = val.replace(' ', '').replace(',', '')
                    try:
                        profit = float(val)
                        if abs(profit) > 0:  # Skip zero-profit rows
                            profits.append(profit)
                        break
                    except ValueError:
                        continue
    
    return profits


def extract_from_csv(filepath):
    """Extract trade profits from CSV file."""
    profits = []
    
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        # Try to detect delimiter
        sample = f.read(4096)
        f.seek(0)
        
        sniffer = csv.Sniffer()
        try:
            dialect = sniffer.sniff(sample, delimiters=',;\t')
        except csv.Error:
            dialect = csv.excel
        
        reader = csv.reader(f, dialect)
        
        # Read header to find profit column
        header = next(reader, None)
        if header:
            # Find profit column index
            profit_idx = None
            for i, col in enumerate(header):
                col_lower = col.strip().lower()
                if col_lower in ('profit', 'p/l', 'pnl', 'p&l', 'gain', 'net profit'):
                    profit_idx = i
                    break
            
            if profit_idx is None:
                # Default to last column
                profit_idx = len(header) - 1
            
            for row in reader:
                if len(row) > profit_idx:
                    val = row[profit_idx].strip().replace(' ', '').replace(',', '')
                    try:
                        profit = float(val)
                        if abs(profit) > 0:
                            profits.append(profit)
                    except ValueError:
                        continue
        else:
            # No header - try single column
            f.seek(0)
            for line in f:
                val = line.strip().replace(',', '')
                try:
                    profit = float(val)
                    if abs(profit) > 0:
                        profits.append(profit)
                except ValueError:
                    continue
    
    return profits


def extract_from_simple(filepath):
    """Extract from simple one-column profit list."""
    profits = []
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            val = line.strip().replace(',', '')
            try:
                profit = float(val)
                if abs(profit) > 0:
                    profits.append(profit)
            except ValueError:
                continue
    return profits


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 prepare_trades.py <input_file> [output_file]")
        print("\nSupported inputs:")
        print("  - MT5 Strategy Tester HTML report (.html)")
        print("  - MT5 Strategy Tester CSV export (.csv)")
        print("  - Simple profit list (one value per line)")
        sys.exit(1)
    
    input_file = Path(sys.argv[1])
    output_file = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("trades.csv")
    
    if not input_file.exists():
        print(f"Error: {input_file} not found")
        sys.exit(1)
    
    print(f"Reading: {input_file}")
    
    # Detect format and extract
    ext = input_file.suffix.lower()
    
    if ext == '.html' or ext == '.htm':
        profits = extract_from_html(input_file)
        format_name = "HTML report"
    elif ext == '.csv':
        profits = extract_from_csv(input_file)
        format_name = "CSV"
    else:
        profits = extract_from_simple(input_file)
        format_name = "simple text"
    
    if not profits:
        print(f"Error: No trade profits found in {format_name} file")
        print("\nTroubleshooting:")
        print("  - For HTML reports: Make sure you right-click > 'Save as Report' in Strategy Tester")
        print("  - For CSV: Ensure the file has a 'Profit' column")
        print("  - For simple text: One profit value per line (positive for wins, negative for losses)")
        sys.exit(1)
    
    # Write output
    with open(output_file, 'w', newline='') as f:
        f.write("Profit\n")
        for p in profits:
            f.write(f"{p:.2f}\n")
    
    # Stats
    wins = [p for p in profits if p > 0]
    losses = [p for p in profits if p < 0]
    
    print(f"\n✅ Extracted {len(profits)} trades from {format_name}")
    print(f"   Wins: {len(wins)} | Losses: {len(losses)} | Win Rate: {len(wins)/len(profits)*100:.1f}%")
    print(f"   Avg Win: ${sum(wins)/len(wins):.2f}" if wins else "   No wins")
    print(f"   Avg Loss: ${sum(losses)/len(losses):.2f}" if losses else "   No losses")
    print(f"   Total P&L: ${sum(profits):.2f}")
    print(f"   Expectancy: ${sum(profits)/len(profits):.2f}/trade")
    print(f"\n📁 Output: {output_file}")
    print(f"\nNext steps:")
    print(f"  1. Copy {output_file} to your MT5 MQL5\\Files\\ directory")
    print(f"  2. Run MonteCarlo_RiskAssessor.mq5 in MetaTrader 5")


if __name__ == "__main__":
    main()
