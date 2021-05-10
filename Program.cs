using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAT602_tester
{
    class Program
    {
        static void Main(string[] args)
        {
            DataAccess aDataAccess = new DataAccess();
            Console.WriteLine("Message is " +aDataAccess.AddUserName("Zoic"));
            Console.ReadLine();
        }
    }
}
