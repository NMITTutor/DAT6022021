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

            // Testing addUserName --existing user name
            Console.WriteLine("Testing AddUserName");
            Console.WriteLine("===============================================");

            Console.WriteLine("Message is " + aDataAccess.AddUserName("Zoic"));
            Console.WriteLine("----------------------------------------------");
            // Testing Get All Players
            Console.WriteLine("Testing Get All Players");
            Console.WriteLine("===============================================");

            foreach ( var p in aDataAccess.GetAllPlayers())
            {
                Console.WriteLine(p.UserName + " " + p.Strength);
            }
            Console.WriteLine("----------------------------------------------");

            Console.ReadLine();
        }
    }

}
